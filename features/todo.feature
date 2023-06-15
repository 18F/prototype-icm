# @untrusted
# When I run report "2021 Fair Lending Referrals"
# And I set filter "" to ""
# Then I see 9 from CFPB
# And 5 from FDIC
# And 3 from NCUA


# @trusted
# When I run report "2021 Fair Lending Referrals"
# Then I see 2 from CFPB
# And 1 from FDIC
# And 2 from NCUA


# @trusted
# When I run report "Fair Lending Referrals to DOJ 2001-2021, All Referrals"
# Then the checksum of the CSV is "b10a8db164e0754105b7a99be72e3fe5"
