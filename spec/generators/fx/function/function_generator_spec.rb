require "spec_helper"
require "generators/fx/function/function_generator"

describe Fx::Generators::FunctionGenerator, :generator do
  it "creates a function definition file, and a migration" do
    migration = file("db/migrate/create_function_test.rb")
    function_definition = file("db/functions/test_v01.sql")

    run_generator ["test"]

    expect(function_definition).to exist
    expect(migration).to be_a_migration
    expect(migration_file(migration)).to contain "CreateFunctionTest"
  end

  context "creating a function with the given arguments" do
    it "creates a function definition file, and a migration" do
      migration = file("db/migrate/create_function_test.rb")
      function_definition = file("db/functions/test_v01.sql")

      run_generator ["test", "arguments" => "(a int, b int)"]

      expect(function_definition).to exist
      expect(migration).to be_a_migration
      expect(migration_file(migration)).to contain "CreateFunctionTest"
      expect(migration_file(migration)).to contain %Q(arguments: "(a int, b int)")
    end
  end

  it "updates an existing function" do
    with_function_definition(
      name: "test",
      version: 1,
      sql_definition: "hello",
    ) do
      allow(Dir).to receive(:entries).and_return(["test_v01.sql"])
      migration = file("db/migrate/update_function_test_to_version_2.rb")
      function_definition = file("db/functions/test_v02.sql")

      run_generator ["test"]

      expect(function_definition).to exist
      expect(migration).to be_a_migration
      expect(migration_file(migration)).
        to contain("UpdateFunctionTestToVersion2")
    end
  end
end
