CLASS zcl_wasm_i64_sub DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_wasm_instruction.

    CLASS-METHODS parse
      IMPORTING !io_body TYPE REF TO zcl_wasm_binary_stream
      RETURNING VALUE(ri_instruction) TYPE REF TO zif_wasm_instruction.
  PRIVATE SECTION.
    CLASS-DATA gi_singleton TYPE REF TO zif_wasm_instruction.
ENDCLASS.

CLASS zcl_wasm_i64_sub IMPLEMENTATION.

  METHOD parse.
    IF gi_singleton IS INITIAL.
      gi_singleton = NEW zcl_wasm_i64_sub( ).
    ENDIF.
    ri_instruction = gi_singleton.
  ENDMETHOD.

  METHOD zif_wasm_instruction~execute.

* https://webassembly.github.io/spec/core/exec/instructions.html#t-mathsf-xref-syntax-instructions-syntax-binop-mathit-binop

    ASSERT io_memory->stack_length( ) >= 2.

    DATA(lo_val1) = CAST zcl_wasm_i64( io_memory->stack_pop( ) ).
    DATA(lo_val2) = CAST zcl_wasm_i64( io_memory->stack_pop( ) ).

    io_memory->stack_push( zcl_wasm_i64=>from_signed( lo_val2->get_signed( ) - lo_val1->get_signed( ) ) ).

  ENDMETHOD.

ENDCLASS.
