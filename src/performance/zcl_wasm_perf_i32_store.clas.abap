CLASS zcl_wasm_perf_i32_store DEFINITION PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS run RAISING zcx_wasm.
ENDCLASS.

CLASS zcl_wasm_perf_i32_store IMPLEMENTATION.

  METHOD run.

    CONSTANTS lc_iterations TYPE i VALUE 12000.

    DATA lo_module TYPE REF TO zcl_wasm_module.

    DATA(li_instruction) = CAST zif_wasm_instruction( NEW zcl_wasm_i32_store(
      iv_align  = zcl_wasm_memory=>c_alignment_32bit
      iv_offset = 32 ) ).

    DATA(lo_memory) = NEW zcl_wasm_memory( ).
    lo_memory->set_linear( CAST zif_wasm_memory_linear( NEW zcl_wasm_memory_linear(
      iv_min = 1
      iv_max = 1 ) ) ).

    TRY.
        DO lc_iterations TIMES.
          lo_memory->mi_stack->push( zcl_wasm_i32=>from_signed( 32 ) ).
          lo_memory->mi_stack->push( zcl_wasm_i32=>from_signed( 32 ) ).
          li_instruction->execute(
            io_memory = lo_memory
            io_module = lo_module ).
        ENDDO.
      CATCH zcx_wasm_branch.
        ASSERT 1 = 2.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
