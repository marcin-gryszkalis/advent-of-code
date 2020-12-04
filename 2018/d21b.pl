use integer;
my %v;

$r5 = 0;

L: while (1)
{
    $r4 = $r5 | 65536;

    $r5 = 13431073;

    while (1)
    {
        $r3 = $r4 & 255;
        $r5 += $r3;
        $r5 &= 16777215;
        $r5 *= 65899;
        $r5 &= 16777215;
        if ($r4 < 256)
        {
            exit if exists $v{$r5};
            {
                exit;
            }
            print "$r5\n";
            $v{$r5} = 1;
            next L;
        }

        $r3 = 0;

        while (1)
        {
            $r2 = $r3 + 1;
            $r2 *= 256;

            if ($r2 > $r4)
            {
                $r4 = $r3;
                last;
            }

            $r3++;
        }
    }
}

    #ip 1
    #  0  seti 123 _ 5        r5 = 123
    #  1  bani 5 456 5        r5 = r5 & 456
    #  2  eqri 5 72 5         if (r5 == 72)
    #  3  addr 5 1 1              goto 7 else goto 6 -> goto 1
    #  4  seti 0 _ 1          goto 1

    #  5  seti 0 6 5          r5 = 0

    #  6  bori 5 65536 4      r4 = r5 | 65536
    #  7  seti 13431073 4 5   r5 = 13431073

    #  8  bani 4 255 3        r3 = r4 & 255
    #  9  addr 5 3 5          r5 = r5 + r3
    # 10  bani 5 16777215 5   r5 = r5 & 16777215
    # 11  muli 5 65899 5      r5 = r5 * 65899
    # 12  bani 5 16777215 5   r5 = r5 & 16777215
    # 13  gtir 256 4 3        if (256 > r4)
    # 14  addr 3 1 1              goto 16 -> goto 28 else goto 15 -> goto 17
    # 15  addi 1 1 1          goto 17

    # 16  seti 27 _ 1         goto 28!

    # 17  seti 0 _ 3          r3 = 0

    # 18  addi 3 1 2          r2 = r3 + 1 = 1
    # 19  muli 2 256 2        r2 = r2 * 256 = 256
    # 20  gtrr 2 4 2          if (r2 > r4) -- (256 > r4) -> r2
    # 21  addr 2 1 1              goto +r2+1 = goto 26 else goto 22 -> goto 24
    # 22  addi 1 1 1          goto 24
    # 23  seti 25 _ 1         goto 26
    # 24  addi 3 1 3          r3++
    # 25  seti 17 8 1         goto 18

    # 26  setr 3 _ 4          r4 = r3
    # 27  seti 7 _ 1          goto 8

    # 28  eqrr 5 0 3          if (r5 == r0)
    # 29  addr 3 1 1              HALT else goto 6
    # 30  seti 5 _ 1          goto 6

