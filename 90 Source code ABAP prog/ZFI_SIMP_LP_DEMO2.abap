*&---------------------------------------------------------------------*
*& Report ZFI_SIMP_LP_DEMO
*&---------------------------------------------------------------------*
*& Amelin A. 2024
* LP demo. Simplex solver. Find min BOM value
*&---------------------------------------------------------------------*
REPORT zfi_simp_lp_demo2.

****Constants
CONSTANTS:
  lc_modelname TYPE genios_name VALUE 'DEMO',
  SolverID     TYPE genios_solverid VALUE 'SIMP'.

****Types
TYPES: BEGIN OF tt_comp,
         mat   TYPE genios_name,
         n     TYPE genios_float,
         p     TYPE genios_float,
         k     TYPE genios_float,
         price TYPE genios_float,
         qnty  TYPE genios_float,
         koef  TYPE genios_float,
       END OF tt_comp,
       ttt_comp TYPE STANDARD TABLE OF tt_comp,
       ttt_res  TYPE STANDARD TABLE OF char1024.

****GlobVars
DATA:
  it_comp TYPE ttt_comp,
  TimeLim TYPE genios_int4 VALUE 300,
  p_n     TYPE i,
  p_p     TYPE i,
  p_k     TYPE i,
  p_Qnty  TYPE i,
  gt_text TYPE ttt_res.

****ScrVars
DATA:
  row_id                 TYPE lvc_t_roid WITH HEADER LINE,
  row_i                  TYPE lvc_s_row,
  col_i                  TYPE lvc_s_col,
  g_okcode               TYPE syucomm,
  alv_comp               TYPE REF TO cl_gui_alv_grid,
  go_textedit            TYPE REF TO cl_gui_textedit,
  g_custom_container     TYPE REF TO cl_gui_custom_container,
  g_custom_container_res TYPE REF TO cl_gui_custom_container,
  gt_fieldcat            TYPE lvc_t_fcat.

****MainClass
CLASS lcl_report DEFINITION.
  PUBLIC SECTION.
    METHODS:
      set_init_comp_data,
      set_init_blend_data,
      init_log,
      add_log IMPORTING text TYPE char1024,
      set_alv_fcat,
      run,
      pbo_0100,
      pai_0100,
      solve IMPORTING n_tot TYPE genios_float
                      p_tot TYPE genios_float
                      k_tot TYPE genios_float
                      q_tot TYPE genios_float.
ENDCLASS.

****ALVHandler
CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_data_changed_finished
        FOR EVENT data_changed_finished OF cl_gui_alv_grid
        IMPORTING e_modified et_good_cells,
      handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.
ENDCLASS.

**********************************************************************
START-OF-SELECTION.
  DATA(lo_report) = NEW lcl_report( ).
  DATA: gr_event_handler TYPE REF TO lcl_event_handler .
  lo_report->set_init_comp_data( ).
  lo_report->set_init_blend_data( ).
  lo_report->init_log( ).
  lo_report->add_log( 'Not calculated yet!' ).
  lo_report->run( ).
**********************************************************************
CLASS lcl_report IMPLEMENTATION.
**********************************************************************
  METHOD set_init_comp_data.
*Raw materials:
    CLEAR: it_comp, it_comp[].
    APPEND VALUE #( mat = 'X01'  n = 12 p = 12 k = 76 price = 35 qnty = 10 )  TO it_comp.
    APPEND VALUE #( mat = 'X02'  n = 20 p = 18 k = 62 price = 52 qnty = 13 )  TO it_comp.
    APPEND VALUE #( mat = 'X03'  n = 12 p = 18 k = 70 price = 40 qnty = 20 )  TO it_comp.
    APPEND VALUE #( mat = 'X04'  n = 20 p = 14 k = 66 price = 46 qnty = 5 )  TO it_comp.
    APPEND VALUE #( mat = 'X05'  n = 10 p = 15 k = 75 price = 43 qnty = 1 )  TO it_comp.
    APPEND VALUE #( mat = 'X06'  n = 13 p = 12 k = 75 price = 32 qnty = 1 )  TO it_comp.
    APPEND VALUE #( mat = 'X07'  n = 12 p = 17 k = 71 price = 54 qnty = 1 )  TO it_comp.
    APPEND VALUE #( mat = 'X08'  n = 23 p = 13 k = 64 price = 41 qnty = 1 )  TO it_comp.
    APPEND VALUE #( mat = 'X09'  n = 50 p = 13 k = 37 price = 83 qnty = 1 )  TO it_comp.
    APPEND VALUE #( mat = 'X10'  n = 10 p = 70 k = 20 price = 91 qnty = 1 )  TO it_comp.
  ENDMETHOD.
**********************************************************************
  METHOD set_init_blend_data.
*Total default blend characteristics:
    p_n = 15.
    p_p = 15.
    p_k = 70.
    p_qnty = 1.
  ENDMETHOD.
**********************************************************************
  METHOD init_log.
    CLEAR: gt_text, gt_text[].
*Clean up a koefs (from prev runs)
    LOOP AT it_comp ASSIGNING FIELD-SYMBOL(<clr>).
      CLEAR <clr>-koef.
    ENDLOOP.
  ENDMETHOD.
**********************************************************************
  METHOD add_log.
    APPEND  text  TO gt_text.
  ENDMETHOD.
**********************************************************************
  METHOD run.
    CALL SCREEN 0100.
  ENDMETHOD.
**********************************************************************
  METHOD solve.
    me->init_log( ).
    GET TIME STAMP FIELD DATA(ts).
    me->add_log( '>>>>>>New calculation started. Time:'  && |{ ts  TIMESTAMP = USER }| ).
    me->add_log( 'Target Blend:' && |{ q_tot && 'Kg;' &&  'N:' && n_tot && '%;P:' && p_tot && '%K:' && k_tot }| && '%. Optimization by price -> min' ).
*Start of calc opt solution
* 1) create a genios environment object
    DATA(lo_env) = cl_genios_environment=>get_environment( ).
    DATA: lx_env TYPE REF TO cx_genios_environment.
    TRY.
* 2) create a genios model (with a context-unique name)
        DATA(lo_model) = lo_env->create_model( lc_modelname ).
      CATCH cx_genios_environment INTO lx_env.
        me->add_log( CONV #( lx_env->get_text( ) ) ) .
        EXIT.
    ENDTRY.
* 3) fill the model with data
* 3.1) create the objective object
    DATA(lo_obj) = lo_model->create_objective( if_genios_model_c=>gc_obj_minimization ).
    DATA(lo_lin_n) = lo_model->create_linearconstraint( iv_name = 'n'     iv_type = if_genios_model_c=>gc_con_greaterorequal iv_righthandside = n_tot ).
    DATA(lo_lin_p) = lo_model->create_linearconstraint( iv_name = 'p'     iv_type = if_genios_model_c=>gc_con_greaterorequal iv_righthandside = p_tot ).
    DATA(lo_lin_k) = lo_model->create_linearconstraint( iv_name = 'k'     iv_type = if_genios_model_c=>gc_con_greaterorequal iv_righthandside = k_tot ).
    DATA(lo_lin_t) = lo_model->create_linearconstraint( iv_name = 'total' iv_type = if_genios_model_c=>gc_con_equal          iv_righthandside = 1  ).
    DATA: lo_x    TYPE REF TO cl_genios_variable,
          lv_s_n  LIKE LINE OF gt_text,
          lv_s_p  LIKE LINE OF gt_text,
          lv_s_k  LIKE LINE OF gt_text,
          lv_s_pr LIKE LINE OF gt_text.
    CLEAR: lv_s_n, lv_s_p, lv_s_k.
**********************************************************************
    me->add_log( |{  '>>>LP Model:' }| ).
    LOOP AT it_comp ASSIGNING FIELD-SYMBOL(<comp>).
      DATA(lv_pl) = ' '.
*    me->add_log( |{ 'RawMat:' &&  <comp>-mat && '|N:' && <comp>-n && '|P:' && <comp>-p && '|K:' && <comp>-k && '|Price:' && <comp>-price }| ).
      IF sy-tabix NE 1.
        lv_pl = '+'.
      ENDIF.
      lv_s_n  = lv_s_n  &&  lv_pl && |{ <comp>-n }|     && '*(' && |{ <comp>-mat }| && ')' .
      lv_s_p  = lv_s_p  &&  lv_pl && |{ <comp>-p }|     && '*(' && |{ <comp>-mat }| && ')' .
      lv_s_k  = lv_s_k  &&  lv_pl && |{ <comp>-k }|     && '*(' && |{ <comp>-mat }| && ')' .
      lv_s_pr = lv_s_pr &&  lv_pl && |{ <comp>-price }| && '*(' && |{ <comp>-mat }| && ')' .
* 3.2) create the needed variables
      lo_x = lo_model->create_variable( iv_name = <comp>-mat iv_type = if_genios_model_c=>gc_var_continuous iv_upperbound = 1 ).
* 3.3) add the monom for the objective function
*      this is the coefficient for each variable in the objective function
      lo_obj->add_monom( io_variable = lo_x iv_coefficient = <comp>-price   ). "material price
* 3.4) add the linear constraints with their monomes (coefficients for the variables
      lo_lin_n->add_monom( io_variable = lo_x iv_coefficient = <comp>-n ).
      lo_lin_p->add_monom( io_variable = lo_x iv_coefficient = <comp>-p ).
      lo_lin_k->add_monom( io_variable = lo_x iv_coefficient = <comp>-k ).
      lo_lin_t->add_monom( io_variable = lo_x iv_coefficient = 1 ).
      DATA(lo_lin_q) = lo_model->create_linearconstraint( iv_name = |{ 'Q' && <comp>-mat }| iv_type = if_genios_model_c=>gc_con_lessorequal iv_righthandside = ( <comp>-qnty  ) ).
      lo_lin_q->add_monom( io_variable = lo_x iv_coefficient = ( q_tot  ) ).
**********************************************************************
    ENDLOOP.
    me->add_log(  'F(x) =' && |{ lv_s_pr }| && ' -> min'  ).
    me->add_log( |{ lv_s_n }| && '>=' && |{  n_tot }| && '*(Σ(Xn))' ).
    me->add_log( |{ lv_s_p }| && '>=' && |{  p_tot }| && '*(Σ(Xn))' ).
    me->add_log( |{ lv_s_k }| && '>=' && |{  k_tot }| && '*(Σ(Xn))' ).
    LOOP AT it_comp ASSIGNING FIELD-SYMBOL(<log>).
      me->add_log( |{ q_tot && '*(' && <log>-mat && ')<=' && <log>-qnty  }| ).
    ENDLOOP.
    me->add_log( |{  'Σ(Xn) =' && 1 }| ).
**********************************************************************
* 4) as the model is filled, we now create a solver with a ID out of tx genios_solver (in this case, the default SIMPLEX solver)
    DATA:
      lo_solver TYPE REF TO cl_genios_solver,
      lx_solver TYPE REF TO cx_genios_solver.
    TRY.
        lo_solver ?= lo_env->create_solver( SolverID ).
      CATCH cx_genios_environment INTO lx_env.
        me->add_log( CONV #( lx_env->get_text( ) ) ) .
        EXIT.
    ENDTRY.

* 4.1) load the model into the solver and solve it
    DATA:
      ls_result TYPE genioss_solver_result,
      lo_param  TYPE REF TO cl_genios_parameter.
    TRY.
        lo_param = NEW cl_genios_parameter( iv_solver_id = lo_solver->get_solverid( ) ).
        lo_param->mv_timelimit = TimeLim. " its a good idea to se a runtime - its only relevant for MILP runs, but ...
        lo_param->mv_logging = 'X'. "to GENIOSD_* tables
        lo_solver->load_model( lo_model ).
        ls_result = lo_solver->solve( lo_param ).
      CATCH cx_genios_solver INTO lx_solver.
        me->add_log( CONV #( lx_env->get_text( ) ) ) .
        EXIT.
    ENDTRY.

* 4.2) evaluate the results
    DATA:
      lt_variables   TYPE geniost_variable,
      ls_variable    TYPE genioss_variable,
      lv_primalvalue TYPE genios_float,
      lv_name        TYPE string.
    IF ( ls_result-solution_status = if_genios_solver_result_c=>gc_optimal
       OR ls_result-solution_status = if_genios_solver_result_c=>gc_abortfeasible ).
* 4.3) found a solution => output the objective value as well as the variable values
      lv_primalvalue = lo_obj->get_value( ). "res Price
      me->add_log( '>>>Solution:' ).
      me->add_log( 'Steps to solve:' && |{ ls_result-nb_nodes }| && ';Time to solve:' && |{ ls_result-solve_time  }| ).
      me->add_log( 'Minimum Price(per 1 Kg)=' && |{ lv_primalvalue }| ).
      lt_variables = lo_model->get_variables( ).
      LOOP AT lt_variables INTO ls_variable.
        lv_primalvalue = 0.
        lv_name = ls_variable-variable_ref->gv_name.
        lv_primalvalue = ls_variable-variable_ref->get_primalvalue( ). "res xN
        IF lv_primalvalue <> 0.
          me->add_log( |{ lv_name && '=' &&  lv_primalvalue && '%' }| ).
          READ TABLE it_comp WITH KEY mat = lv_name ASSIGNING FIELD-SYMBOL(<koef>).
          IF <koef> IS ASSIGNED.
            <koef>-koef = lv_primalvalue.
            UNASSIGN <koef>.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
    ULINE.
* 4.4) output the solution status
    IF ( ls_result-solution_status = if_genios_solver_result_c=>gc_optimal ).
      me->add_log(  'Found solution is optimal' ).
    ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_abortfeasible ).
      me->add_log( 'Solver aborted with a feasible solution').
    ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_abortinfeasible ).
      me->add_log( 'Solver aborted with an infeasible solution' ).
    ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_failinfeasible ).
      me->add_log( 'Solver failed due to infeasibility' ).
    ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_solutionlimitreached ).
      me->add_log( 'Solution limit reached, but the a solution has been found' ).
    ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_timelimitinfeasible ).
      me->add_log( 'Time limit reached and the solution is infeasible' ).
    ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_unknown ).
      me->add_log( 'Solution status is unknown' ).
    ENDIF.
    me->add_log( '>>>Check results:' ).
    me->add_log( '>Optimal BOM:' ).
    DATA: res_n  TYPE genios_float VALUE 0,
          res_p  TYPE genios_float VALUE 0,
          res_k  TYPE genios_float VALUE 0,
          res_pr TYPE genios_float VALUE 0.
    LOOP AT it_comp ASSIGNING FIELD-SYMBOL(<check>) WHERE koef IS NOT INITIAL.
      res_n = res_n + ( <check>-n * <check>-koef ).
      res_p = res_p + ( <check>-p * <check>-koef ).
      res_k = res_k + ( <check>-k * <check>-koef ).
      res_pr = res_pr + ( <check>-price * <check>-koef ).
      me->add_log( |{ <check>-mat }| && '=' && |{ ( <check>-koef * q_tot ) }|  && 'Kg' ).
    ENDLOOP.
    me->add_log( |{ '>Blend characteristics:' }| ).
    me->add_log( 'N% =' && |{ res_n }| ).
    me->add_log( 'P% =' && |{ res_p }| ).
    me->add_log( 'K% =' && |{ res_k }| ).
    me->add_log(  'Total blend price =' && |{ res_pr * q_tot }| ).
* 5) some cleanup
    IF ( lo_env IS BOUND ).
      lo_env->destroy_solver( SolverID ).
      lo_env->destroy_model( lc_modelname ).
    ENDIF.
    GET TIME STAMP FIELD ts.
    me->add_log( '>>>>>>Calculation end. Time:'  && |{ ts  TIMESTAMP = USER }| ).
  ENDMETHOD.
**********************************************************************
  METHOD set_alv_fcat.
    gt_fieldcat = VALUE #( BASE gt_fieldcat
       ( fieldname   = 'MAT'
         ref_field   = 'MAT'
         scrtext_l   = 'Material'
         scrtext_m   = 'Material'
         scrtext_s   = 'Material'
         reptext     = 'Material'
         seltext     = 'Material'
         edit = 'X'
         key = 'X'
        )
        ( fieldname   = 'N'
         ref_field   = 'N'
         scrtext_l   = 'N,%'
         scrtext_m   = 'N,%'
         scrtext_s   = 'N,%'
         reptext     = 'N,%'
         seltext     = 'N,%'
         exponent    = 0
         decimals_o = 1
         edit = 'X'
        )
        ( fieldname   = 'P'
         ref_field   = 'P'
         scrtext_l   = 'P,%'
         scrtext_m   = 'P,%'
         scrtext_s   = 'P,%'
         reptext     = 'P,%'
         seltext     = 'P,%'
         exponent    = 0
         decimals_o = 1
         edit = 'X'
        )
        ( fieldname   = 'K'
         ref_field   = 'K'
         scrtext_l   = 'K,%'
         scrtext_m   = 'K,%'
         scrtext_s   = 'K,%'
         reptext     = 'K,%'
         seltext     = 'K,%'
         exponent    = 0
         decimals_o = 1
         edit = 'X'
        )
        ( fieldname   = 'PRICE'
         ref_field   = 'PRICE'
         scrtext_l   = 'Price'
         scrtext_m   = 'Price'
         scrtext_s   = 'Price'
         reptext     = 'Price'
         seltext     = 'Price'
         exponent    = 0
         decimals_o = 2
         edit = 'X'
         emphasize = 'C501'
        )
        ( fieldname   = 'QNTY'
         ref_field   = 'QNTY'
         scrtext_l   = 'Qnty'
         scrtext_m   = 'Qnty'
         scrtext_s   = 'Qnty'
         reptext     = 'Qnty'
         seltext     = 'Qnty'
         exponent    = 0
         decimals_o = 2
         edit = 'X'
         tech        = ''
         emphasize = 'C301'
        )
        ( fieldname   = 'KOEF'
         ref_field   = 'KOEF'
         scrtext_l   = '>>>Res:koef'
         scrtext_m   = '>>>Res:koef'
         scrtext_s   = '>>>Res:koef'
         reptext     = '>>>Res:koef'
         seltext     = '>>>Res:koef'
         exponent    = 0
         decimals_o  = 2
         tech        = ''
         emphasize = 'C500'
        )
    ).
  ENDMETHOD.
**********************************************************************
  METHOD pbo_0100.
    IF g_custom_container IS INITIAL.
      g_custom_container = NEW cl_gui_custom_container( container_name = 'CONT1' ).
      alv_comp = NEW cl_gui_alv_grid( i_parent = g_custom_container ).
      me->set_alv_fcat( ).
      alv_comp->set_table_for_first_display( CHANGING it_outtab = it_comp it_fieldcatalog = gt_fieldcat[] ).
      CREATE OBJECT gr_event_handler.
      SET HANDLER gr_event_handler->handle_data_changed_finished FOR alv_comp.
      alv_comp->set_ready_for_input( EXPORTING i_ready_for_input = 1 ).
      alv_comp->register_edit_event( EXPORTING i_event_id = cl_gui_alv_grid=>mc_evt_modified ).
    ELSE.
      alv_comp->refresh_table_display( ).
    ENDIF.
    IF g_custom_container_res IS INITIAL.
      g_custom_container_res = NEW cl_gui_custom_container( container_name = 'CONT2' ).
      go_textedit = NEW cl_gui_textedit( parent = g_custom_container_res ).
      go_textedit->set_readonly_mode( EXPORTING readonly_mode  = 1 ).
    ENDIF.
    go_textedit->set_text_as_r3table( EXPORTING table  = gt_text ).
  ENDMETHOD.
**********************************************************************
  METHOD pai_0100.
    CASE g_okcode.
      WHEN 'BACK' OR 'EXIT' OR 'CANC'.
        SET SCREEN 0.
        LEAVE SCREEN.
      WHEN 'CALC'.
        me->solve( n_tot = CONV #( p_n ) p_tot = CONV #( p_p ) k_tot = CONV #( p_k ) q_tot = CONV #( p_qnty ) ).
    ENDCASE.
    CLEAR g_okcode.
  ENDMETHOD.
ENDCLASS.

*----------------------------------------------------------------------*
* CLASS lcl_event_handler IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_event_handler IMPLEMENTATION .
  METHOD handle_data_changed_finished .
    DATA: ls_modi TYPE lvc_s_modi.
    CHECK e_modified = 'X'.
    LOOP AT et_good_cells INTO ls_modi.
      MOVE ls_modi-row_id TO row_id-row_id.
      MOVE ls_modi-row_id TO row_i-index.
      MOVE ls_modi-fieldname TO col_i-fieldname.
      READ TABLE it_comp ASSIGNING FIELD-SYMBOL(<mod>) INDEX ls_modi-row_id.
      IF <mod> IS ASSIGNED.
        CASE ls_modi-fieldname.
          WHEN 'N'. <mod>-n = ls_modi-value.
          WHEN 'P'. <mod>-p = ls_modi-value.
          WHEN 'K'. <mod>-k = ls_modi-value.
          WHEN 'PRICE'. <mod>-price = ls_modi-value.
          WHEN 'MAT'. <mod>-mat = ls_modi-value.
          WHEN OTHERS.
        ENDCASE.
        UNASSIGN <mod>.
      ENDIF.
    ENDLOOP.
    alv_comp->refresh_table_display( ).
    alv_comp->set_current_cell_via_id(
        is_row_id    = row_i
        is_column_id = col_i ).
    cl_gui_cfw=>flush( ).
  ENDMETHOD. "handle_data_changed_finished
  METHOD: handle_data_changed.
  ENDMETHOD. "handle_data_changed
ENDCLASS. "lcl_event_handler IMPLEMENTATION

**********************************************************************
MODULE pbo_0100 OUTPUT.
  SET PF-STATUS 'PF_100'.
  SET TITLEBAR 'TB_100'.
  lo_report->pbo_0100( ).
ENDMODULE.

*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  lo_report->pai_0100( ).
ENDMODULE.