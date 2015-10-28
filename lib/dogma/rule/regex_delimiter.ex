defmodule Dogma.Rule.RegexDelimiter do
  @moduledoc """
  A rule that disallows Regular Expression sigils that use unconventional
  delimiters. By default the rule requires '/' to be used as the delimiter
  for all regex sigils. There is an exception for regexes which contain a '/'
  that would otherwise need to be escaped.

  The following are valid:
    ~r/[a-z]/i
    ~r/test/
    ~r/
      multiline-regex
      /
    ~r{some/path/}

  These are invalid:
    ~r{[a-z]}
    ~r(test)i

  This default can be overridden with the "delimiter" option in your mix config.
  Specify the leading character for paired delimiters like '(' or '{'.
  """

  alias Dogma.Error

  def test(script), do: test(script, [])
  def test(script, []), do: test(script, delimiter: "/")
  def test(script, delimiter: delimiter) do
    script.tokens
    |> regex_lines
    |> Enum.map(&(check_delimiter(&1, script.lines, delimiter)))
    |> Enum.reject(&(&1 == nil))
  end

  defp regex_lines(tree, acc \\ [])
  defp regex_lines([], acc) do
    Enum.reverse(acc)
  end

  defp regex_lines([{:sigil, line, ?r, _, _} | rest], acc) do
    regex_lines(rest, [line | acc])
  end

  defp regex_lines([{_, _, children} | rest], acc)
  when is_list(children) do
    regex_lines(children ++ rest, acc)
  end

  defp regex_lines([{_, children} | rest], acc)
  when is_list(children) do
    regex_lines(children ++ rest, acc)
  end

  defp regex_lines([_ | rest], acc) do
    regex_lines(rest, acc)
  end

  defp check_delimiter({line, _,_} = location, lines, delimiter) do
    [ character_used | sigil_content ] = get_regex_chars(location, lines)
    expected_character = delimiter |> String.to_char_list |> hd

    delimiter_in_content? = Enum.member?(sigil_content, expected_character)
    if character_used != expected_character && !delimiter_in_content? do
      error(line, delimiter)
    end
  end

  defp get_regex_chars({line_num, start_col, end_col}, lines) do
    {_, line} = Enum.at(lines, line_num - 1)
    line
    |> String.to_char_list
    |> Enum.slice(start_col + 1, end_col - start_col - 1)
  end

  defp error(line, delimiter) do
    %Error{
      rule: __MODULE__,
      message:  "Use '#{delimiter}' to delimit Regular Expessions.",
      line: line,
    }
  end
end
