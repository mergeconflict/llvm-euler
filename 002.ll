declare i32 @printf(i8* noalias nocapture, ...)

@format = internal constant [4 x i8] c"%d\0a\00"

define i1 @isEven(i64 %n) {
  %remainder = urem i64 %n, 2
  %rv = icmp eq i64 %remainder, 0
  ret i1 %rv
}

define i64 @go(i64 %prev, i64 %cur, i64 %acc) {
  %done = icmp uge i64 %cur, 4000000
  br i1 %done, label %a, label %b
a:
  ret i64 %acc
b:
  %isEven = call i1 @isEven(i64 %cur)
  br i1 %isEven, label %c, label %d
c:
  %sum = add i64 %acc, %cur
  br label %d
d:
  %newAcc = phi i64 [%acc, %b], [%sum, %c]
  %next = add i64 %prev, %cur
  %rv = musttail call i64 @go(i64 %cur, i64 %next, i64 %newAcc)
  ret i64 %rv
}

define void @main() {
  %result = call i64 @go(i64 1, i64 2, i64 0)
  call i32 (i8*, ...) @printf(i8* getelementptr ([4 x i8], [4 x i8]* @format, i64 0, i64 0), i64 %result)
  ret void
}
