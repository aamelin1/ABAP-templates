*&---------------------------------------------------------------------*
*& Report ZFI_SIMP_LP_DEMO
*&---------------------------------------------------------------------*
*& Amelin A. 2024
* LP demo. Simplex solver. Find min BOM value
* Пример поиска оптимальной спецификации. Решает систему линейных неравенств (симплекс метод)
*
*   Тестовый пример:
*     Система ограничений по содержанию
*       12x1 + 20x2 + 12x3 + 20x4 ≥ 15(x1 + x2 + x3 + x4)
*       12x1 + 18x2 + 18x3 + 14x4 ≥ 15(x1 + x2 + x3 + x4)
*       76x1 + 62x2 + 70x3 + 66x4 = 70(x1 + x2 + x3 + x4)
*
*     Ограничение по количеству
*       x1 + x2 + x3 + x4 = 1 (кг)
*
*     Целевая функция (минимизация себестоимости)
*       35x1 + 52x2 + 40x3 + 46x4  → min
*
*     Для проверки (решение)
*	      x1 = 0,25;
*	      x2 = 0;
*	      x3 = 0,375;
*	      x4 = 0,375
*&---------------------------------------------------------------------*
REPORT zfi_simp_lp_demo.

PARAMETERS:
  SolverID TYPE genios_solverid DEFAULT 'SIMP'.
PARAMETERS:
  p_pr1 TYPE i DEFAULT 35,
  p_n1  TYPE i DEFAULT 12,
  p_p1  TYPE i DEFAULT 12,
  p_k1  TYPE i DEFAULT 76.
SELECTION-SCREEN ULINE.
PARAMETERS:
  p_pr2 TYPE i DEFAULT 52,
  p_n2  TYPE i DEFAULT 20,
  p_p2  TYPE i DEFAULT 18,
  p_k2  TYPE i DEFAULT 62.
SELECTION-SCREEN ULINE.
PARAMETERS:
  p_pr3 TYPE i DEFAULT 40,
  p_n3  TYPE i DEFAULT 12,
  p_p3  TYPE i DEFAULT 18,
  p_k3  TYPE i DEFAULT 70.
SELECTION-SCREEN ULINE.
PARAMETERS:
  p_pr4 TYPE i DEFAULT 46,
  p_n4  TYPE i DEFAULT 20,
  p_p4  TYPE i DEFAULT 14,
  p_k4  TYPE i DEFAULT 66.
SELECTION-SCREEN ULINE.
PARAMETERS:
  p_nt TYPE i DEFAULT 15,
  p_pt TYPE i DEFAULT 15,
  p_kt TYPE i DEFAULT 70,
  p_tt TYPE i DEFAULT 1.

**********************************************************************
CONSTANTS:
  lc_modelname TYPE genios_name VALUE 'DEMO'.

**********************************************************************
START-OF-SELECTION.
  CHECK p_tt NE 0. "divide check
*Variables
  DATA:
    pr_1  TYPE genios_float,
    pr_2  TYPE genios_float,
    pr_3  TYPE genios_float,
    pr_4  TYPE genios_float,
    n_1   TYPE genios_float,
    n_2   TYPE genios_float,
    n_3   TYPE genios_float,
    n_4   TYPE genios_float,
    p_1   TYPE genios_float,
    p_2   TYPE genios_float,
    p_3   TYPE genios_float,
    p_4   TYPE genios_float,
    k_1   TYPE genios_float,
    k_2   TYPE genios_float,
    k_3   TYPE genios_float,
    k_4   TYPE genios_float,
    x_1   TYPE genios_float,
    x_2   TYPE genios_float,
    x_3   TYPE genios_float,
    x_4   TYPE genios_float,
    n_tot TYPE genios_float,
    p_tot TYPE genios_float,
    k_tot TYPE genios_float,
    tt    TYPE genios_float,
    lo_x1 TYPE REF TO cl_genios_variable,
    lo_x2 TYPE REF TO cl_genios_variable,
    lo_x3 TYPE REF TO cl_genios_variable,
    lo_x4 TYPE REF TO cl_genios_variable.


* 0) copy sscr data to float variables
  pr_1  = p_pr1.
  pr_2  = p_pr2.
  pr_3  = p_pr3.
  pr_4  = p_pr4.
  n_1   = p_n1.
  n_2   = p_n2.
  n_3   = p_n3.
  n_4   = p_n4.
  p_1   = p_p1.
  p_2   = p_p2.
  p_3   = p_p3.
  p_4   = p_p4.
  k_1   = p_k1.
  k_2   = p_k2.
  k_3   = p_k3.
  k_4   = p_k4.
  n_tot = p_nt.
  p_tot = p_pt.
  k_tot = p_kt.
  tt    = p_tt.

* Input data. Log
  WRITE: / |{ 'Source data:' }|.
  WRITE: / |{ 'Raw material 1: N-' && p_n1 && ';P-' && p_p1 && ';K-' && p_k1 && ';Price:' && p_pr1 }|.
  WRITE: / |{ 'Raw material 2: N-' && p_n2 && ';P-' && p_p2 && ';K-' && p_k2 && ';Price:' && p_pr2 }|.
  WRITE: / |{ 'Raw material 3: N-' && p_n3 && ';P-' && p_p3 && ';K-' && p_k3 && ';Price:' && p_pr3 }|.
  WRITE: / |{ 'Raw material 4: N-' && p_n4 && ';P-' && p_p4 && ';K-' && p_k4 && ';Price:' && p_pr4 }|.
  WRITE: / |{ 'Target blend: N-' && p_nt && ';P-' && p_pt && ';K-' && p_kt }|.
  ULINE.


  DATA:
    lo_env TYPE REF TO cl_genios_environment,
    lx_env TYPE REF TO cx_genios_environment,
    lv_msg TYPE string.

* 1) create a genios environment object
  lo_env = cl_genios_environment=>get_environment( ).

  DATA:
    lo_model TYPE REF TO cl_genios_model.
  TRY.
* 2) create a genios model (with a context-unique name)
      lo_model = lo_env->create_model( lc_modelname ).
    CATCH cx_genios_environment INTO lx_env.
      lv_msg = lx_env->get_text( ).
      WRITE: lv_msg, /.
      EXIT.
  ENDTRY.

* 3) fill the model with data
* 3.1) create the objective object
  DATA:
    lo_obj TYPE REF TO cl_genios_objective.
  lo_obj = lo_model->create_objective( if_genios_model_c=>gc_obj_minimization ).

* 3.2) create the needed variables
  lo_x1 = lo_model->create_variable( iv_name = 'x1' iv_type = if_genios_model_c=>gc_var_continuous ).
  lo_x2 = lo_model->create_variable( iv_name = 'x2' iv_type = if_genios_model_c=>gc_var_continuous ).
  lo_x3 = lo_model->create_variable( iv_name = 'x3' iv_type = if_genios_model_c=>gc_var_continuous ).
  lo_x4 = lo_model->create_variable( iv_name = 'x4' iv_type = if_genios_model_c=>gc_var_continuous ).

* 3.3) add the monom for the objective function
*      this is the coefficient for each variable in the objective function
  lo_obj->add_monom( io_variable = lo_x1 iv_coefficient = pr_1 ). "material price
  lo_obj->add_monom( io_variable = lo_x2 iv_coefficient = pr_2 ).
  lo_obj->add_monom( io_variable = lo_x3 iv_coefficient = pr_3 ).
  lo_obj->add_monom( io_variable = lo_x4 iv_coefficient = pr_4 ).

* 3.4) add the linear constraints with their monomes (coefficients for the variables
  DATA: lo_lin TYPE REF TO cl_genios_linearconstraint.

  lo_lin = lo_model->create_linearconstraint( iv_name = 'n' iv_type = if_genios_model_c=>gc_con_greaterorequal iv_righthandside = n_tot ).
  lo_lin->add_monom( io_variable = lo_x1 iv_coefficient = n_1 ).
  lo_lin->add_monom( io_variable = lo_x2 iv_coefficient = n_2 ).
  lo_lin->add_monom( io_variable = lo_x3 iv_coefficient = n_3 ).
  lo_lin->add_monom( io_variable = lo_x4 iv_coefficient = n_4 ).

  lo_lin = lo_model->create_linearconstraint( iv_name = 'p' iv_type = if_genios_model_c=>gc_con_greaterorequal iv_righthandside = p_tot ).
  lo_lin->add_monom( io_variable = lo_x1 iv_coefficient = p_1 ).
  lo_lin->add_monom( io_variable = lo_x2 iv_coefficient = p_2 ).
  lo_lin->add_monom( io_variable = lo_x3 iv_coefficient = p_3 ).
  lo_lin->add_monom( io_variable = lo_x4 iv_coefficient = p_4 ).

  lo_lin = lo_model->create_linearconstraint( iv_name = 'k' iv_type = if_genios_model_c=>gc_con_greaterorequal iv_righthandside = k_tot ).
  lo_lin->add_monom( io_variable = lo_x1 iv_coefficient = k_1 ).
  lo_lin->add_monom( io_variable = lo_x2 iv_coefficient = k_2 ).
  lo_lin->add_monom( io_variable = lo_x3 iv_coefficient = k_3 ).
  lo_lin->add_monom( io_variable = lo_x4 iv_coefficient = k_4 ).

  lo_lin = lo_model->create_linearconstraint( iv_name = 'total' iv_type = if_genios_model_c=>gc_con_equal iv_righthandside = 1 ).
  lo_lin->add_monom( io_variable = lo_x1 iv_coefficient = 1 ).
  lo_lin->add_monom( io_variable = lo_x2 iv_coefficient = 1 ).
  lo_lin->add_monom( io_variable = lo_x3 iv_coefficient = 1 ).
  lo_lin->add_monom( io_variable = lo_x4 iv_coefficient = 1 ).

* 4) as the model is filled, we now create a solver with a ID out of tx genios_solver (in this case, the default SIMPLEX solver)
  DATA:
    lo_solver TYPE REF TO cl_genios_solver,
    lx_solver TYPE REF TO cx_genios_solver.
  TRY.
      lo_solver ?= lo_env->create_solver( SolverID ).
    CATCH cx_genios_environment INTO lx_env.
      lv_msg = lx_env->get_text( ).
      WRITE: lv_msg, /.
      EXIT.
  ENDTRY.

* 4.1) load the model into the solver and solve it
  DATA:
    ls_result TYPE genioss_solver_result,
    lo_param  TYPE REF TO cl_genios_parameter.
  TRY.
      CREATE OBJECT lo_param
        EXPORTING
          iv_solver_id = lo_solver->get_solverid( ).
      lo_param->mv_timelimit = 300. " its a good idea to se a runtime - its only relevant for MILP runs, but ...

      lo_solver->load_model( lo_model ).
      ls_result = lo_solver->solve( lo_param ).
    CATCH cx_genios_solver INTO lx_solver.
      lv_msg = lx_solver->get_text( ).
      WRITE: lv_msg, /.
      EXIT.
  ENDTRY.

* 4.2) evaluate the results
  DATA:
    lt_variables   TYPE geniost_variable,
    ls_variable    TYPE genioss_variable,
    lv_primalvalue TYPE genios_float,
    lv_name        TYPE string,
    lv_index       TYPE string.
  IF ( ls_result-solution_status = if_genios_solver_result_c=>gc_optimal
     OR ls_result-solution_status = if_genios_solver_result_c=>gc_abortfeasible ).
* 4.3) found a solution => output the objective value as well as the variable values
    lv_primalvalue = lo_obj->get_value( ).
    WRITE: / 'Function to minimize'.
    WRITE: / 'F(x): ', |{ p_pr1 && '*x1+' && p_pr2 && '*x2+' &&  p_pr3 && '*x3+' && p_pr4 && '*x4 =>min' }|.
    WRITE: / 'Restrictions:'.
    WRITE: / |{ p_n1 && '*x1+' &&  p_n2 && '*x2+' &&  p_n3 && '*x3+' &&  p_n4 && '*x4 >=' &&  n_tot && '(x1+x2+x3+x4)' }|.
    WRITE: / |{ p_p1 && '*x1+' &&  p_p2 && '*x2+' &&  p_p3 && '*x3+' &&  p_p4 && '*x4 >=' &&  p_tot && '(x1+x2+x3+x4)' }|.
    WRITE: / |{ p_k1 && '*x1+' &&  p_k2 && '*x2+' &&  p_k3 && '*x3+' &&  p_k4 && '*x4 >=' &&  k_tot && '(x1+x2+x3+x4)' }|.
    WRITE: / |{ tt && '*x1+' &&  tt && '*x2+' &&  tt && '*x3+' &&  tt && '*x4 =' &&  tt && '(x1+x2+x3+x4)' }|.
    ULINE.
    WRITE: / 'Results:'.
    WRITE: /'Min price: ', |{ lv_primalvalue * tt }|.       "#EC NOTEXT
    lt_variables = lo_model->get_variables( ).
    LOOP AT lt_variables INTO ls_variable.
      lv_primalvalue = 0.
      lv_name = ls_variable-variable_ref->gv_name.
      lv_index = ls_variable-variable_index.
      lv_primalvalue = ls_variable-variable_ref->get_primalvalue( ).
      WRITE: / lv_name,' = ',|{ lv_primalvalue * tt }|.
      IF lv_name = 'x1'.
        x_1 = lv_primalvalue * tt.
      ELSEIF lv_name = 'x2'.
        x_2 = lv_primalvalue * tt.
      ELSEIF lv_name = 'x3'.
        x_3 = lv_primalvalue * tt.
      ELSEIF lv_name = 'x4'.
        x_4 = lv_primalvalue * tt.
      ENDIF.
    ENDLOOP.
    WRITE: / 'Final blend characteristics:'.
    WRITE: /  'N:' && |{ ( ( ( x_1 * p_n1 ) + ( x_2 * p_n2 ) + ( x_3 * p_n3 ) + ( x_4 * p_n4 ) ) / tt ) }| && '%'.
    WRITE: /  'P:' && |{ ( ( ( x_1 * p_p1 ) + ( x_2 * p_p2 ) + ( x_3 * p_p3 ) + ( x_4 * p_p4 ) ) / tt ) }| && '%'.
    WRITE: /  'K:' && |{ ( ( ( x_1 * p_k1 ) + ( x_2 * p_k2 ) + ( x_3 * p_k3 ) + ( x_4 * p_k4 ) ) / tt ) }| && '%'.
  ENDIF.
  ULINE.
* 4.4) output the solution status
  IF ( ls_result-solution_status = if_genios_solver_result_c=>gc_optimal ).
    WRITE: /,'Found solution is optimal'.
  ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_abortfeasible ).
    WRITE: /,'Solver aborted with a feasible solution'.
  ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_abortinfeasible ).
    WRITE: /,'Solver aborted with an infeasible solution'.
  ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_failinfeasible ).
    WRITE: /,'Solver failed due to infeasibility'.
  ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_solutionlimitreached ).
    WRITE: /,'Solution limit reached, but the a solution has been found'.
  ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_timelimitinfeasible ).
    WRITE: /,'Time limit reached and the solution is infeasible'.
  ELSEIF ( ls_result-solution_status = if_genios_solver_result_c=>gc_unknown ).
    WRITE: /,'Solution status is unknown'.
  ENDIF.

* 5) some cleanup
  IF ( lo_env IS BOUND ).
    lo_env->destroy_solver( SolverID ).
    lo_env->destroy_model( lc_modelname ).
  ENDIF.