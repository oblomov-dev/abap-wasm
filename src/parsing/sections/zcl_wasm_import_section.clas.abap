CLASS zcl_wasm_import_section DEFINITION PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS parse
      IMPORTING
        !io_body          TYPE REF TO zcl_wasm_binary_stream
      RAISING
        zcx_wasm.
ENDCLASS.

CLASS zcl_wasm_import_section IMPLEMENTATION.

  METHOD parse.

* https://webassembly.github.io/spec/core/binary/modules.html#binary-importsec

    DO io_body->shift_u32( ) TIMES.
      DATA(lv_mod) = io_body->shift_utf8( ).
      " WRITE / lv_mod.
      DATA(lv_mn) = io_body->shift_utf8( ).
      " WRITE / lv_mn.

      DATA(lv_desc) = io_body->shift( 1 ).
      CASE lv_desc.
        WHEN '00'.
          DATA(lv_typeidx) = io_body->shift_u32( ).
        WHEN '01'.
          DATA(lv_reftype) = io_body->shift( 1 ).

          DATA(lv_limit) = io_body->shift( 1 ).
          CASE lv_limit.
            WHEN '00'.
              DATA(lv_min) = io_body->shift_u32( ).
              DATA(lv_max) = 0.
            WHEN '01'.
              lv_min = io_body->shift_u32( ).
              lv_max = io_body->shift_u32( ).
            WHEN OTHERS.
              RAISE EXCEPTION NEW zcx_wasm( text = |parse_import: todo| ).
          ENDCASE.
        WHEN '02'.
          lv_limit = io_body->shift( 1 ).
          CASE lv_limit.
            WHEN '00'.
              lv_min = io_body->shift_u32( ).
              lv_max = 0.
            WHEN '01'.
              lv_min = io_body->shift_u32( ).
              lv_max = io_body->shift_u32( ).
            WHEN OTHERS.
              RAISE EXCEPTION NEW zcx_wasm( text = |parse_import: todo| ).
          ENDCASE.
        WHEN '03'.
          DATA(lv_valtype) = io_body->shift( 1 ).
          DATA(lv_mut) = io_body->shift( 1 ).
        WHEN OTHERS.
          RAISE EXCEPTION NEW zcx_wasm( text = |parse_import: todo| ).
      ENDCASE.

    ENDDO.

  ENDMETHOD.

ENDCLASS.