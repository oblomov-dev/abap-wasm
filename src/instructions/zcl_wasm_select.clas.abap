CLASS zcl_wasm_select DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_wasm_instruction.

    CLASS-METHODS parse
      IMPORTING !io_body TYPE REF TO zcl_wasm_binary_stream
      RETURNING VALUE(ri_instruction) TYPE REF TO zif_wasm_instruction.
ENDCLASS.

CLASS zcl_wasm_select IMPLEMENTATION.

  METHOD parse.
    ri_instruction = NEW zcl_wasm_select( ).
  ENDMETHOD.

  METHOD zif_wasm_instruction~execute.
* https://webassembly.github.io/spec/core/exec/instructions.html#xref-syntax-instructions-syntax-instr-parametric-mathsf-select-t-ast

    DATA lo_c TYPE REF TO zcl_wasm_i32.

    TRY.
        lo_c ?= io_memory->stack_pop( ).
      CATCH cx_sy_move_cast_error.
        RAISE EXCEPTION NEW zcx_wasm( text = 'select: expected i32' ).
    ENDTRY.

    DATA(lo_val1) = io_memory->stack_pop( ).
    DATA(lo_val2) = io_memory->stack_pop( ).
* todo: validate val1 and val2 are of same type

    IF lo_c->get_signed( ) = 0.
      io_memory->stack_push( lo_val1 ).
    ELSE.
      io_memory->stack_push( lo_val2 ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
