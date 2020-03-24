Module Type foo. Parameter A : Prop. End foo.
Module Type bar. Parameter B : Prop. End bar.

Module foobar <: foo <: bar.
Fail End foobar.
Include foo <+ bar.
End foobar.

Fail Module barfoo <: foo <: bar := foo.
Fail Module barfoo <: foo <: bar := bar.
Module barfoo <: foo <: bar := bar <+ foo.

Module foo' : foo := foo.
