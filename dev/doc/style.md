> Style uniformity is more important than style itself

(Kernigan & Pike, The Practice of Programming)

## OCaml Style
  - Indent your code (using tuareg default)
  - No strong constraints in formatting `let in`; possible styles are:
    ```ocaml
    let x = ... in
    let x =
      ... in
    let
      x = ...
    in
    ```
  - But: no extra indentation before a `in` coming on next line,
    otherwise, it first shifts further and further on the right,
    reducing the amount of space available; second, it is not robust to
    insertion of a new `let`
  - It is established usage to have space around `|` as in
    ```ocaml
    match c with
    | [] | [a] -> ...
    | a::b::l -> ...
    ```
  - In a one-line `match`, it is preferred to have no `|` in front of
    the first case (this saves spaces for the match to hold in the line)
  - From about 8.2, the tendency is to use the following format which
    limit excessive indentation while providing an interesting "block" aspect
    ```ocaml
    type t =
    | A
    | B of stuff

    let f expr = match expr with
    | A -> ...
    | B x -> ...

    let f expr = function
    | A -> ...
    | B x -> ...
    ```
  - Add spaces around operators (spaces improve readability)
  - The common usage is to write `let x,y = ... in ...` rather than
    `let (x,y) = ... in ...`
  - Parenthesizing with either `(` and `)` or with `begin` and `end` is
    common practice
  - Preferred layout for conditionals:
    ```ocaml
    if condition then
      ...
    else
      ...
    ```
  - In case of effects in branches, use `begin ... end` rather than
    parentheses
    ```ocaml
    if condition then begin
      instr1;
      instr2
    end else begin
      instr3;
      instr4
    end
    ```
  - If the first branch raises an exception, avoid having an `else`-branch, i.e.:
    ```ocaml
    if condition then                     if condition then error "foo";
      error "foo"          ----->         bar
    else
      bar
    ```
  - It is the usage not to use `;;` to end OCaml sentences (however,
    inserting `;;` can be useful for debugging syntax errors crossing
    the boundary of functions)
  - Relevant options in tuareg:
    ```elisp
    (setq tuareg-in-indent 2)
    (setq tuareg-with-indent 0)
    (setq tuareg-function-indent 0)
    (setq tuareg-let-always-indent nil)
    ```

## Coding methodology
  - No `try ... with _ -> ...` which catches even Sys.Break (Ctrl-C),
    Out_of_memory, Stack_overflow, etc.
    At least, use `try with e when Errors.noncritical e -> ...`
    (to be detailed, Pierre L. ?)
  - Do not abuse of fancy combinators: sometimes what a `let rec` loop
    does is more readable and simpler to grasp than what a `fold` does
  - Do not break abstractions: if an internal property is hidden
    behind an interface, do no rely on it in code which uses this
    interface (e.g. do not use `List.map` thinking it is left-to-right,
    use `map_left`)
  - In particular, do not use `=` on abstract types: there is no
    reason a priori that it is the intended equality on this type; use the
    `equal` function normally provided with the abstract type
  - Avoid polymorphically typed `=` whose implementation is not
    optimized in OCaml and which has moreover no reason to be the
    intended implementation of the equality when it comes to be
    instantiated on a particular type (e.g. use `List.mem_f`,
    `List.assoc_f`, rather than `List.mem`, `List.assoc`, etc, unless it is
    absolutely clear that `=` will implement the intended equality, and
    with the right complexity)
  - Any new general-purpose enough combinator on `list` should be put in
    `cList.ml`, on type `option` in `cOpt.ml`, etc.
  - Unless of a good reason not to so, follow the style of the
    surrounding code in the same file as much as possible,
    the general guidelines are otherwise "let spacing breaths" (we
    have large screen nowadays), "make your code easy to read and
    to understand"
  - Document what is tricky, but do not overdocument, sometimes the
    choice of names and the structuration of the code is a better
    documentation than a long discourse; use of unicode in comments is
    welcome if it can make comments more readable (then
    `toggle-enable-multibyte-characters` can help when using the
    debugger in emacs)
  - All of initial `open File`, or of small-scope `File.(...)`, or
    per-ident `File.foo` are common practices

## Choice of variable names
  - Be consistent when naming from one function to another
  - Be consistent with the naming adopted in the functions from the
    same file, or with the naming used elsewhere by similar functions
  - Use variable names which express meaning
  - Keep `cst` for constants and avoid it for constructors which is
    otherwise a source of confusion
  - For constructors, use `cstr` in type `constructor` (resp. `cstru` in
    `constructor puniverse`); avoid `constr` for `constructor` which
    could be think as the name of an arbitrary `Constr.t`
  - For inductive types, use `ind` in the type `inductive` (resp `indu`
    in `inductive puniverse`)
  - For `env`, use `env`
  - For `evar_map`, use `sigma`, with tolerance into `evm` and `evd`
  - For `named_context` or `rel_context`, use `ctxt` or `ctx` (or `sign`)
  - For formal/actual indices of inductive types: `realdecls`, `realargs`
  - For formal/actual parameters of inductive types: `paramdecls`, `paramargs`
  - For terms, use e.g. `c`, `b`, `a`, ...
  - If a term is known to be a function: `f`, ...
  - If a term is known to be a type: `t`, `u`, `typ`, ...
  - For a declaration, use `d` or `decl`
  - For errors, exceptions, use `e`

## Common OCaml pitfalls
  - In `match ... with Case1 -> try ... with ... -> ... | Case2 -> ...`, or in
    `match ... with Case1 -> match ... with SubCase -> ... | Case2 -> ...`
    parentheses are needed around the `try` and the inner `match`
  - Even if streams are lazy, the `Pp.(++)` combinator is strict and
    forces the evaluation of its arguments (use a `lazy` or a `fun () ->`)
    to make it lazy explicitly
  - In `if ... then ... else ... ++ ...`, the default parenthesizing
    is somehow counter-intuitive; use `(if ... then ... else ...) ++ ...`
  - In `let myspecialfun = mygenericfun args`, be sure that it does no
    do side-effect; prefer otherwise `let mygenericfun arg =
    mygenericfun args arg` to ensure that the function is evaluated at
    runtime
