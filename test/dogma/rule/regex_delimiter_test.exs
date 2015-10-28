defmodule Dogma.Rule.RegexDelimiterTest do
  use ShouldI

  alias Dogma.Script
  alias Dogma.Error
  alias Dogma.Rule.RegexDelimiter

  defp lint(script) do
    script
    |> Script.parse!("foo.ex")
    |> RegexDelimiter.test
  end

  should "not error when using the correct delimiter" do
    errors = """
    ~r/test/
    ~r/
      [a-z]
      /
    """ |> lint
    assert errors == []
  end

  should "error if the wrong delimiter is used" do
    errors = """
    ~r(test)
    ~r{
      [a-z]
      }
    """ |> lint
    expected_errors =[
      %Error{
        rule: RegexDelimiter,
        message: "Use '/' to delimit Regular Expessions.",
        line: 1,
      },
      %Error{
        rule: RegexDelimiter,
        message: "Use '/' to delimit Regular Expessions.",
        line: 2,
      },
    ]
    assert errors == expected_errors
  end

  should "not error if the wrong delimiter is used to avoid escaping" do
    errors = """
    ~r{some/path/}
    """ |> lint
    assert errors == []
  end

  should "allow customization of delimiter" do
    errors = """
    ~r(test)
    ~r/
      [a-z]
      /
    """
    |> Script.parse("foo.ex")
    |> RegexDelimiter.test( delimiter: "(" )

    expected_errors = [
      %Error{
        rule: RegexDelimiter,
        message: "Use '(' to delimit Regular Expessions.",
        line: 2,
      },]

    assert errors == expected_errors
 end
end
