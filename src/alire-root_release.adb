
with Ada.Directories;

with Alire.Containers;
with Alire.Index;
with Alire.Origins;
with Alire.Requisites;

package body Alire.Root_Release is

   Root : Alire.Containers.Release_H;
   --  Root dependency (the working project). If Is_Empty we know we must recompile,
   --  unless the hash already matches. In this case, we know the project file is
   --  missing the Set call

   -------------
   -- Current --
   -------------

   function Current return Releases.Release is (Root.Element);

   ------------
   -- Is_Set --
   ------------

   function Is_Set return Boolean is
      (not Root.Is_Empty);

   ---------
   -- Set --
   ---------

   function Set (Project    : Alire.Project_Name;
                 Version    : Semantic_Versioning.Version;
                 Dependencies : Conditional.Dependencies := Conditional.For_Dependencies.Empty)
                 return Releases.Release
   is
      use Origins;

      Descr : constant String := "working copy of " & Project;
      Rel : constant Releases.Release :=
              Alire.Releases.New_Release (Project,
                                          Descr (Descr'First .. Descr'First - 1 +
                                              Natural'Min (Descr'Length, Max_Description_Length)),
                                          Version,
                                          New_Filesystem (Ada.Directories.Current_Directory),
                                          Dependencies,
                                          Properties         => Index.No_Properties,
                                          Private_Properties => Index.No_Properties,
                                          Available          => Requisites.No_Requisites);
   begin
      if Index.Exists (Project, Version) then
         --  This is done to ensure that properties are all available
         Trace.Debug ("Storing pre-indexed release of root project");
         Root.Replace_Element (Index.Find (Project, Version));
      else
         Trace.Debug ("Storing unindexed release of root project");
         Root.Replace_Element (Rel);
      end if;

      return Rel;
   end Set;

end Alire.Root_Release;