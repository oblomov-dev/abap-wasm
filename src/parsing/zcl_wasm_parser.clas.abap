CLASS zcl_wasm_parser DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS parse
      IMPORTING
        !iv_wasm         TYPE xstring
      RETURNING
        VALUE(ro_module) TYPE REF TO zcl_wasm_module
      RAISING
        zcx_wasm.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_wasm_parser IMPLEMENTATION.


  METHOD parse.

    CONSTANTS lc_magic   TYPE x LENGTH 4 VALUE '0061736D'.
    CONSTANTS lc_version TYPE x LENGTH 4 VALUE '01000000'.

    DATA(lo_stream) = NEW zcl_wasm_binary_stream( iv_wasm ).

* https://webassembly.github.io/spec/core/binary/modules.html#binary-module
    IF lo_stream->shift( 4 ) <> lc_magic.
      RAISE EXCEPTION NEW zcx_wasm( text = |unexpected magic number| ).
    ENDIF.
    IF lo_stream->shift( 4 ) <> lc_version.
      RAISE EXCEPTION NEW zcx_wasm( text = |unexpected version| ).
    ENDIF.

    WHILE lo_stream->get_length( ) > 0.
* https://webassembly.github.io/spec/core/binary/modules.html#sections
      DATA(lv_section) = lo_stream->shift( 1 ).
      DATA(lv_length) = lo_stream->shift_u32( ).
      DATA(lo_body) = NEW zcl_wasm_binary_stream( lo_stream->shift( lv_length ) ).

      " WRITE: / 'body:', lo_body->get_data( ).

      CASE lv_section.
        WHEN zif_wasm_sections=>gc_section_custom.
* https://webassembly.github.io/spec/core/binary/modules.html#binary-customsec
* "ignored by the WebAssembly semantics"
          CONTINUE.
        WHEN zif_wasm_sections=>gc_section_type.
          DATA(lt_types) = zcl_wasm_type_section=>parse( lo_body ).
        WHEN zif_wasm_sections=>gc_section_import.
* todo
          zcl_wasm_import_section=>parse( lo_body ).
        WHEN zif_wasm_sections=>gc_section_function.
          DATA(lt_functions) = zcl_wasm_function_section=>parse( lo_body ).
        WHEN zif_wasm_sections=>gc_section_table.
* todo
          zcl_wasm_table_section=>parse( lo_body ).
        WHEN zif_wasm_sections=>gc_section_memory.
* todo
          zcl_wasm_memory_section=>parse( lo_body ).
        WHEN zif_wasm_sections=>gc_section_global.
* todo
          zcl_wasm_global_section=>parse( lo_body ).
        WHEN zif_wasm_sections=>gc_section_export.
          DATA(lt_exports) = zcl_wasm_export_section=>parse( lo_body ).
        WHEN zif_wasm_sections=>gc_section_start.
* https://webassembly.github.io/spec/core/binary/modules.html#start-section
* todo
          DATA(lv_funcidx) = lo_body->shift_u32( ).
        WHEN zif_wasm_sections=>gc_section_element.
* todo
          zcl_wasm_element_section=>parse( lo_body ).
        WHEN zif_wasm_sections=>gc_section_code.
          DATA(lt_codes) = zcl_wasm_code_section=>parse( lo_body ).
        WHEN zif_wasm_sections=>gc_section_data.
          zcl_wasm_data_section=>parse( lo_body ).
        WHEN zif_wasm_sections=>gc_section_data_count.
          DATA(lv_data_count) = lo_body->shift_u32( ).
        WHEN OTHERS.
          RAISE EXCEPTION NEW zcx_wasm( text = |unknown section: { lv_section }| ).
      ENDCASE.
    ENDWHILE.

    ro_module = NEW #(
      it_types     = lt_types
      it_codes     = lt_codes
      it_exports   = lt_exports
      it_functions = lt_functions ).

  ENDMETHOD.

ENDCLASS.
