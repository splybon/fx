require "acceptance_helper"

describe "User manages functions" do
  it "handles simple functions" do
    successfully "rails generate fx:function test"
    write_function_definition "test_v01", <<-EOS
      CREATE OR REPLACE FUNCTION test()
      RETURNS text AS $$
      BEGIN
          RETURN 'test';
      END;
      $$ LANGUAGE plpgsql;
    EOS
    successfully "rake db:migrate"

    result = execute("SELECT * FROM test() AS result")
    expect(result).to eq("result" => "test")

    successfully "rails generate fx:function test"
    verify_identical_definitions(
      "db/functions/test_v01.sql",
      "db/functions/test_v02.sql",
    )
    write_function_definition "test_v02", <<-EOS
      CREATE OR REPLACE FUNCTION test()
      RETURNS text AS $$
      BEGIN
          RETURN 'testest';
      END;
      $$ LANGUAGE plpgsql;
    EOS
    successfully "rake db:migrate"

    result = execute("SELECT * FROM test() AS result")
    expect(result).to eq("result" => "testest")
  end

  it "handles functions with parameters" do
    successfully "rails generate fx:function adder_integers"
    write_function_definition "adder_integers_v01", <<-EOS
      CREATE FUNCTION adder(x int, y int)
      RETURNS int AS $$
      BEGIN
          RETURN $1 + $2;
      END;
      $$ LANGUAGE plpgsql;
    EOS
    successfully "rake db:migrate"

    result = execute("SELECT * FROM adder(1, 2) AS result")
    expect(result).to eq("result" => 3)

    successfully "rails generate fx:function adder_floats"
    write_function_definition "adder_floats_v01", <<-EOS
      CREATE FUNCTION adder(x float, y float)
      RETURNS float AS $$
      BEGIN
          RETURN $1 + $2;
      END;
      $$ LANGUAGE plpgsql;
    EOS
    successfully "rake db:migrate"

    result = execute("SELECT * FROM adder(1.0, 2.0) AS result")
    expect(result).to eq("result" => 3.0)

    successfully "rake db:rollback"
  end
end
