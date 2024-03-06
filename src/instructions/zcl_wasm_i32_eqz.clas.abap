CLASS zcl_wasm_i32_eqz DEFINITION PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_wasm_instruction.

    CLASS-METHODS parse
      IMPORTING !io_body TYPE REF TO zcl_wasm_binary_stream
      RETURNING VALUE(ri_instruction) TYPE REF TO zif_wasm_instruction.
  PRIVATE SECTION.
    CLASS-DATA gi_singleton TYPE REF TO zif_wasm_instruction.
ENDCLASS.

CLASS zcl_wasm_i32_eqz IMPLEMENTATION.

  METHOD parse.
    IF gi_singleton IS INITIAL.
      gi_singleton = NEW zcl_wasm_i32_eqz( ).
    ENDIF.
    ri_instruction = gi_singleton.
  ENDMETHOD.

  METHOD zif_wasm_instruction~execute.
    ASSERT io_memory->stack_length( ) >= 1.

    DATA(lv_val1) = CAST zcl_wasm_i32( io_memory->stack_pop( ) )->get_signed( ).

    IF lv_val1 = 0.
      io_memory->stack_push( zcl_wasm_i32=>from_signed( 1 ) ).
    ELSE.
      io_memory->stack_push( zcl_wasm_i32=>from_signed( 0 ) ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
