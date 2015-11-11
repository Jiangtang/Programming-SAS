/*
THE TOWER OF HANOI PUZZLE

The puzzle: Given a tower of n disks, each a different size and
initially stacked in increasing size on one of three posts, transfer the
disks to one of the other posts, moving only one disk at a time and
never placing a larger disk on top of a smaller disk.

The solution (quoted from the Usenet rec.puzzles FAQ):

   The best way of thinking of the Towers of Hanoi problem is
   inductively. To move n disks from post 1 to post 2, first move (n-1)
   disks from post 1 to post 3, then move disk n from post 1 to post 2,
   then move (n-1) disks from post 3 to post 2 (same procedure as moving
   (n-1) disks from post 1 to post 3).  In order to figure out how to
   move (n-1) disks from post 1 to post 3, first move (n-2) disks . . .
   .

   As far as an algorithm which straightens out any legal position is
   concerned, the algorithm would go something like this:

   1.  Find the smallest disk.  Call the post that it's on post 1.

   2.  Find the smallest disk which is not on post 1.  This disk is,
   say, size k.  (I am calling the smallest disk size 1 here.)  Call the
   post that disk k is on post 2.  Disks 1 through (k-1) are then all
   stacked up correctly on post 1 disk k is on top of post 2.  This
   follows from the fact that the disks are in a legal postition.

   3.  Move disks 1 through (k-1) from post 1 to post 2, ignoring the
   other disks.  This is just the standard Tower of Hanoi problem for
   (k-1) disks.

   4.  If the disks are not yet correctly arranged, repeat from step 1.

A pseudo-code solution is:

   move(r, A, C, B)
      if r = 1 then do
         print "Move from " A " to " C
         stop
      end

      move(r-1, A, B, C)
      move(1, A, C, B)
      move(r-1, B, C, A)
   end

   ; Start the game
   move(4, "start", "finish", "middle")

The tagset solution uses the `trigger' statement to simulate the calls
to the "move" routine. The $rings array and the $A, $B, and $C
dictionaries substitute for the parameter stack. The statement
`eval $A[] $x' pushes an element on the $A stack and the statement
`unset $A[- 1]' pops the $A stack. The expression `$A[$A]' refers to the
top element on the $A stack.
*/


proc template;
   define tagset tagsets.hanoi;

   define event doc;
      eval $rings[] 4;           /* Initial number of rings - should be small */
      set $A[] 'start';          /* Define the 3 poles, from left-to-right */
      set $B[] 'middle';
      set $C[] 'finish';
      trigger move;             /* Start the game. */
      end;

   define event move;

      put "Move from " $A[$A] " to " $C[$C] nl / breakif $rings[$rings] eq 1;

      eval $rings[] $rings[$rings]-1;
      eval $A[] $A[$A];
      set $temp $B[$B];
      eval $B[] $C[$C];
      eval $C[] $temp;

      trigger move;

      unset $rings[-1];
      unset $A[-1];
      unset $B[-1];
      unset $C[-1];

      eval $rings[] 1;
      eval $A[] $A[$A];
      eval $B[] $B[$B];
      eval $C[] $C[$C];

      trigger move;

      unset $rings[-1];
      unset $A[-1];
      unset $B[-1];
      unset $C[-1];

      eval $rings[] $rings[$rings]-1;
      set $temp $A[$A];
      eval $A[] $B[$B];
      eval $B[] $temp;
      eval $C[] $C[$C];

      trigger move;

      unset $rings[-1];
      unset $A[-1];
      unset $B[-1];
      unset $C[-1];
      end;

   end;
   run;


ods tagsets.hanoi file="hanoi.txt";
ods tagsets.hanoi close;
