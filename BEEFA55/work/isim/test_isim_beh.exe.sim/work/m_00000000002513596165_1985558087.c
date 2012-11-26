/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0xa0883be4 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/0xBEEFA55/BEEFA55/Source/memtest.v";
static unsigned int ng1[] = {0U, 0U};
static const char *ng2 = "tracefile=%s";
static const char *ng3 = "stimulus=%s";
static const char *ng4 = "ERROR: No Stimulus specified. Please specify +stimulus=<filename> to start.";
static unsigned int ng5[] = {1U, 0U};
static const char *ng6 = "r";
static int ng7[] = {2, 0};
static int ng8[] = {0, 0};
static const char *ng9 = "%d %x";
static int ng10[] = {1, 0};
static const char *ng11 = "command = %d value = %x";



static void Initial_22_0(char *t0)
{
    char t4[8];
    char *t1;
    char *t2;
    char *t3;
    char *t5;
    char *t6;
    char *t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    char *t13;
    char *t14;
    char *t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    char *t24;

LAB0:    t1 = (t0 + 4008U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(23, ng0);

LAB4:    xsi_set_current_line(24, ng0);
    t2 = ((char*)((ng1)));
    t3 = (t0 + 1968);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 1);
    xsi_set_current_line(25, ng0);

LAB5:    xsi_set_current_line(25, ng0);
    t2 = (t0 + 3816);
    xsi_process_wait(t2, 10000LL);
    *((char **)t1) = &&LAB6;

LAB1:    return;
LAB6:    xsi_set_current_line(25, ng0);
    t3 = (t0 + 1968);
    t5 = (t3 + 56U);
    t6 = *((char **)t5);
    memset(t4, 0, 8);
    t7 = (t6 + 4);
    t8 = *((unsigned int *)t7);
    t9 = (~(t8));
    t10 = *((unsigned int *)t6);
    t11 = (t10 & t9);
    t12 = (t11 & 1U);
    if (t12 != 0)
        goto LAB10;

LAB8:    if (*((unsigned int *)t7) == 0)
        goto LAB7;

LAB9:    t13 = (t4 + 4);
    *((unsigned int *)t4) = 1;
    *((unsigned int *)t13) = 1;

LAB10:    t14 = (t4 + 4);
    t15 = (t6 + 4);
    t16 = *((unsigned int *)t6);
    t17 = (~(t16));
    *((unsigned int *)t4) = t17;
    *((unsigned int *)t14) = 0;
    if (*((unsigned int *)t15) != 0)
        goto LAB12;

LAB11:    t22 = *((unsigned int *)t4);
    *((unsigned int *)t4) = (t22 & 1U);
    t23 = *((unsigned int *)t14);
    *((unsigned int *)t14) = (t23 & 1U);
    t24 = (t0 + 1968);
    xsi_vlogvar_assign_value(t24, t4, 0, 0, 1);
    goto LAB5;

LAB7:    *((unsigned int *)t4) = 1;
    goto LAB10;

LAB12:    t18 = *((unsigned int *)t4);
    t19 = *((unsigned int *)t15);
    *((unsigned int *)t4) = (t18 | t19);
    t20 = *((unsigned int *)t14);
    t21 = *((unsigned int *)t15);
    *((unsigned int *)t14) = (t20 | t21);
    goto LAB11;

LAB13:    goto LAB1;

}

static void Initial_29_1(char *t0)
{
    char t3[2256];
    char t6[8];
    char t18[8];
    char t27[8];
    char t31[8];
    char *t1;
    char *t2;
    char *t4;
    char *t5;
    char *t7;
    char *t8;
    char *t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    char *t15;
    char *t16;
    char *t17;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    unsigned int t23;
    int t24;
    char *t25;
    char *t26;
    char *t28;
    char *t29;
    char *t30;
    char *t32;
    char *t33;
    char *t34;
    char *t35;

LAB0:    t1 = (t0 + 4256U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(29, ng0);

LAB4:    xsi_set_current_line(32, ng0);
    t2 = (t0 + 2928);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    xsi_vlog_bit_copy(t3, 0, t5, 0, 9001);
    *((int *)t6) = xsi_vlog_valueplusarg(ng2, -1, 2, t0, (char)118, t3, 9001);
    t7 = (t6 + 4);
    *((int *)t7) = 0;
    t8 = (t0 + 2928);
    xsi_vlogvar_assign_value(t8, t3, 0, 0, 9001);
    t9 = (t6 + 4);
    t10 = *((unsigned int *)t9);
    t11 = (~(t10));
    t12 = *((unsigned int *)t6);
    t13 = (t12 & t11);
    t14 = (t13 != 0);
    if (t14 > 0)
        goto LAB5;

LAB6:
LAB7:    xsi_set_current_line(38, ng0);
    t2 = (t0 + 2768);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    xsi_vlog_bit_copy(t3, 0, t5, 0, 9001);
    *((int *)t18) = xsi_vlog_valueplusarg(ng3, -1, 2, t0, (char)118, t3, 9001);
    t7 = (t18 + 4);
    *((int *)t7) = 0;
    t8 = (t0 + 2768);
    xsi_vlogvar_assign_value(t8, t3, 0, 0, 9001);
    memset(t6, 0, 8);
    t9 = (t18 + 4);
    t10 = *((unsigned int *)t9);
    t11 = (~(t10));
    t12 = *((unsigned int *)t18);
    t13 = (t12 & t11);
    t14 = (t13 & 4294967295U);
    if (t14 != 0)
        goto LAB12;

LAB10:    if (*((unsigned int *)t9) == 0)
        goto LAB9;

LAB11:    t15 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t15) = 1;

LAB12:    t16 = (t6 + 4);
    t19 = *((unsigned int *)t16);
    t20 = (~(t19));
    t21 = *((unsigned int *)t6);
    t22 = (t21 & t20);
    t23 = (t22 != 0);
    if (t23 > 0)
        goto LAB13;

LAB14:
LAB15:    xsi_set_current_line(43, ng0);
    t2 = ((char*)((ng5)));
    t4 = (t0 + 2128);
    xsi_vlogvar_assign_value(t4, t2, 0, 0, 1);
    xsi_set_current_line(44, ng0);
    t2 = (t0 + 472);
    t4 = *((char **)t2);
    t2 = (t4 + 4);
    t10 = *((unsigned int *)t2);
    t11 = (~(t10));
    t12 = *((unsigned int *)t4);
    t24 = (t12 & t11);
    t5 = (t0 + 6236);
    *((int *)t5) = t24;

LAB17:    t7 = (t0 + 6236);
    if (*((int *)t7) > 0)
        goto LAB18;

LAB19:    xsi_set_current_line(45, ng0);
    t2 = ((char*)((ng1)));
    t4 = (t0 + 2128);
    xsi_vlogvar_assign_value(t4, t2, 0, 0, 1);
    xsi_set_current_line(48, ng0);
    t2 = (t0 + 2768);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    *((int *)t6) = xsi_vlogfile_file_open_of_valname_ctype(t5, 9001, ng6);
    t7 = (t6 + 4);
    *((int *)t7) = 0;
    t8 = (t0 + 2288);
    xsi_vlogvar_assign_value(t8, t6, 0, 0, 32);
    xsi_set_current_line(49, ng0);
    t2 = ((char*)((ng7)));
    t4 = (t0 + 3088);
    xsi_vlogvar_assign_value(t4, t2, 0, 0, 32);
    xsi_set_current_line(51, ng0);

LAB21:    t2 = (t0 + 3088);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    t7 = ((char*)((ng8)));
    memset(t6, 0, 8);
    xsi_vlog_signed_greater(t6, 32, t5, 32, t7, 32);
    t8 = (t6 + 4);
    t10 = *((unsigned int *)t8);
    t11 = (~(t10));
    t12 = *((unsigned int *)t6);
    t13 = (t12 & t11);
    t14 = (t13 != 0);
    if (t14 > 0)
        goto LAB22;

LAB23:    xsi_set_current_line(61, ng0);
    t2 = (t0 + 2288);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    xsi_vlogfile_fclose(*((unsigned int *)t5));
    xsi_set_current_line(62, ng0);
    xsi_vlog_finish(1);

LAB1:    return;
LAB5:    xsi_set_current_line(32, ng0);

LAB8:    xsi_set_current_line(33, ng0);
    t15 = (t0 + 2928);
    t16 = (t15 + 56U);
    t17 = *((char **)t16);
    xsi_vcd_dumpfile(t17);
    xsi_set_current_line(34, ng0);
    xsi_vcd_dumpvars(t0);
    goto LAB7;

LAB9:    *((unsigned int *)t6) = 1;
    goto LAB12;

LAB13:    xsi_set_current_line(38, ng0);

LAB16:    xsi_set_current_line(39, ng0);
    xsi_vlogfile_write(1, 0, 0, ng4, 1, t0);
    xsi_set_current_line(40, ng0);
    xsi_vlog_finish(1);
    goto LAB15;

LAB18:    xsi_set_current_line(44, ng0);
    t8 = (t0 + 4576);
    *((int *)t8) = 1;
    t9 = (t0 + 4288);
    *((char **)t9) = t8;
    *((char **)t1) = &&LAB20;
    goto LAB1;

LAB20:    t2 = (t0 + 6236);
    t24 = *((int *)t2);
    *((int *)t2) = (t24 - 1);
    goto LAB17;

LAB22:    xsi_set_current_line(51, ng0);

LAB24:    xsi_set_current_line(53, ng0);
    t9 = (t0 + 2288);
    t15 = (t9 + 56U);
    t16 = *((char **)t15);
    t17 = (t0 + 2448);
    t25 = (t17 + 56U);
    t26 = *((char **)t25);
    xsi_vlog_bit_copy(t18, 0, t26, 0, 4);
    t28 = (t0 + 2608);
    t29 = (t28 + 56U);
    t30 = *((char **)t29);
    xsi_vlog_bit_copy(t27, 0, t30, 0, 32);
    *((int *)t31) = xsi_vlogfile_fscanf(*((unsigned int *)t16), ng9, 3, t0, (char)118, t18, 4, (char)118, t27, 32);
    t32 = (t31 + 4);
    *((int *)t32) = 0;
    t33 = (t0 + 2448);
    xsi_vlogvar_assign_value(t33, t18, 0, 0, 4);
    t34 = (t0 + 2608);
    xsi_vlogvar_assign_value(t34, t27, 0, 0, 32);
    t35 = (t0 + 3088);
    xsi_vlogvar_assign_value(t35, t31, 0, 0, 32);
    xsi_set_current_line(54, ng0);
    t2 = (t0 + 3088);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    t7 = ((char*)((ng8)));
    memset(t6, 0, 8);
    xsi_vlog_signed_greater(t6, 32, t5, 32, t7, 32);
    t8 = (t6 + 4);
    t10 = *((unsigned int *)t8);
    t11 = (~(t10));
    t12 = *((unsigned int *)t6);
    t13 = (t12 & t11);
    t14 = (t13 != 0);
    if (t14 > 0)
        goto LAB25;

LAB26:
LAB27:    goto LAB21;

LAB25:    xsi_set_current_line(54, ng0);

LAB28:    xsi_set_current_line(56, ng0);
    t9 = ((char*)((ng10)));
    t15 = (t9 + 4);
    t19 = *((unsigned int *)t15);
    t20 = (~(t19));
    t21 = *((unsigned int *)t9);
    t24 = (t21 & t20);
    t16 = (t0 + 6240);
    *((int *)t16) = t24;

LAB29:    t17 = (t0 + 6240);
    if (*((int *)t17) > 0)
        goto LAB30;

LAB31:    xsi_set_current_line(57, ng0);
    t2 = (t0 + 2448);
    t4 = (t2 + 56U);
    t5 = *((char **)t4);
    t7 = (t0 + 2608);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    xsi_vlogfile_write(1, 0, 0, ng11, 3, t0, (char)118, t5, 4, (char)118, t9, 32);
    goto LAB27;

LAB30:    xsi_set_current_line(56, ng0);
    t25 = (t0 + 4592);
    *((int *)t25) = 1;
    t26 = (t0 + 4288);
    *((char **)t26) = t25;
    *((char **)t1) = &&LAB32;
    goto LAB1;

LAB32:    t2 = (t0 + 6240);
    t24 = *((int *)t2);
    *((int *)t2) = (t24 - 1);
    goto LAB29;

}


extern void work_m_00000000002513596165_1985558087_init()
{
	static char *pe[] = {(void *)Initial_22_0,(void *)Initial_29_1};
	xsi_register_didat("work_m_00000000002513596165_1985558087", "isim/test_isim_beh.exe.sim/work/m_00000000002513596165_1985558087.didat");
	xsi_register_executes(pe);
}
