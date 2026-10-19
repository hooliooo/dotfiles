;; extends

; Macro arguments (e.g. `matches!(...)`) are re-parsed as an injected Rust
; expression; a single expression in parens becomes a parenthesized_expression,
; which nvim-treesitter doesn't indent, so Enter inside `matches!()` dedented.
; While typing the parens are still empty, which parses as a unit_expression
[
  (parenthesized_expression)
  (unit_expression)
] @indent.begin
