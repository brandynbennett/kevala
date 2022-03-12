defmodule KevalaTest do
  use ExUnit.Case

  test "dedupe_employee_csv/1 removes duplicate email or phone by default" do
    csv =
      stream_csv(
        ~s(First Name,Last Name,Email,Phone\n) <>
          ~s(Marge,Simpson,marge@simpsons.com,999-999-9999\n) <>
          ~s(M,Simpson,marge@simpsons.com,111-111-1111\n) <>
          ~s(Homer,Simpson,homer@simpsons.com,888-191-2999\n) <>
          ~s(H,Simpson,h@simpsons.com,888-191-2999)
      )

    assert Kevala.dedupe_employee_csv(csv) ==
             ~s(First Name,Last Name,Email,Phone\n) <>
               ~s(Homer,Simpson,homer@simpsons.com,888-191-2999\n) <>
               ~s(Marge,Simpson,marge@simpsons.com,999-999-9999\n)
  end

  test "dedupe_employee_csv/2 removes duplicate email" do
    csv =
      stream_csv(
        ~s(First Name,Last Name,Email,Phone\n) <>
          ~s(Marge,Simpson,marge@simpsons.com,999-999-9999\n) <>
          ~s(M,Simpson,marge@simpsons.com,111-111-1111\n) <>
          ~s(Homer,Simpson,homer@simpsons.com,888-191-2999\n) <>
          ~s(H,Simpson,h@simpsons.com,888-191-2999)
      )

    assert Kevala.dedupe_employee_csv(csv, :email) ==
             ~s(First Name,Last Name,Email,Phone\n) <>
               ~s(H,Simpson,h@simpsons.com,888-191-2999\n) <>
               ~s(Homer,Simpson,homer@simpsons.com,888-191-2999\n) <>
               ~s(Marge,Simpson,marge@simpsons.com,999-999-9999\n)
  end

  defp stream_csv(csv) do
    {:ok, stream} = StringIO.open(csv)
    stream |> IO.binstream(:line)
  end
end
