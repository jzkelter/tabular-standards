package program;

import java.util.Random;
import java.text.DecimalFormat;
import com.jezhumble.javasysmon.CpuTimes;
import com.jezhumble.javasysmon.JavaSysMon;

public class Simulation extends Thread {

    Agents My_Agents;

    Random RandomGenerator;

    io my_io = new io();


    void Start(boolean Silent, int RandomSeed_, String Folder, int NumberOfMonths, int ShockMonth, double ParameterOfInterest) {

        // Check how much CPU is free for beeing used
        JavaSysMon monitor =   new JavaSysMon();
        monitor.cpuFrequencyInHz();
        monitor.numCpus();
        CpuTimes old_snapshot;
        do {
            try {this.sleep(3000);} catch (Exception e) {System.out.println("Error while letting simulation thread sleep!");};
            old_snapshot = monitor.cpuTimes();
            try {this.sleep(100);} catch (Exception e) {System.out.println("Error while letting simulation thread sleep!");};
            if (monitor.cpuTimes().getCpuUsage(old_snapshot) >= 0.75) {
                System.out.print(".");
            } else {
                break;
            }
        } while (true);




        RandomGenerator = new Random(RandomSeed_);  //(63952);

        ShutdownHook My_ShutdownHook = new ShutdownHook(my_io);
        Runtime.getRuntime().addShutdownHook(My_ShutdownHook);

    // General Paparameter
        int NumberOfHH = 1000;
        int NumberOfFI = 100;

    //Household Parameters
        double HHpar_SavingsProgression = 0.885;
        double HHpar_ResWageChange_Employed = 1;
        double HHpar_ResWageChange_Fired = 1;
        double HHpar_ResWageChange_Unemployed = 0.9;

    //Firm Parameters
        double FIpar_Price_Change_Probability = 0.78;  //0.7
        double FIpar_Price_Change_Speed = 0.019;  //0.23
        double FIpar_Wage_Change_Probability = 0.07;
        double FIpar_Wage_Change_Speed = 0.02;
        double FIpar_Min_Inventory_Fraction = 0.25;
        double FIpar_Max_Inventory_Fraction = 1;
        double FIpar_Min_Profit = 1.025;
        double FIpar_Max_Profit = 1.15;

        my_io.Set_Folder(Folder);

        My_Agents = new Agents(NumberOfHH,NumberOfFI,RandomGenerator.nextInt(),NumberOfMonths,my_io, 7);

        My_Agents.Set_HH_SavingsProgression(HHpar_SavingsProgression);
        My_Agents.Set_HH_ResWageChange_Employed(HHpar_ResWageChange_Employed);
        My_Agents.Set_HH_ResWageChange_Fired(HHpar_ResWageChange_Fired);
        My_Agents.Set_HH_ResWageChange_Unemployed(HHpar_ResWageChange_Unemployed);
        My_Agents.Set_FI_Price(1* ((RandomGenerator.nextDouble()-0.5)/50+1) );      //Make price random in order to have initial conditions across simulations different
        My_Agents.Set_FI_Wage(52* ((RandomGenerator.nextDouble()-0.5)/50+1) );      //Make wage random in order to have initial conditions across simulations different
        My_Agents.Set_FI_Price_Change_Probability(FIpar_Price_Change_Probability);
        My_Agents.Set_FI_Price_Change_Speed(FIpar_Price_Change_Speed);
        My_Agents.Set_FI_Wage_Change_Probability(FIpar_Wage_Change_Probability);
        My_Agents.Set_FI_Wage_Change_Speed(FIpar_Wage_Change_Speed);
        My_Agents.Set_FI_Min_Inventory_Fraction(FIpar_Min_Inventory_Fraction);
        My_Agents.Set_FI_Max_Inventory_Fraction(FIpar_Max_Inventory_Fraction);
        My_Agents.Set_FI_Min_Profit(FIpar_Min_Profit);
        My_Agents.Set_FI_Max_Profit(FIpar_Max_Profit);
        My_Agents.Set_FI_First_Month_Of_Planning(24 + RandomGenerator.nextInt(84));

        my_io.WriteToFile("info.m", "NumberOfMonths = " + NumberOfMonths +"\r\n" +
                                    "NumberOfHH = " + NumberOfHH + "\r\n" +
                                    "NumberOfFI = " + NumberOfFI + "\r\n" +
                                    "HHpar_SavingsProgression = " + HHpar_SavingsProgression + "\r\n" +
                                    "HHpar_ResWageChange_Employed = " + HHpar_ResWageChange_Employed + "\r\n" +
                                    "HHpar_ResWageChange_Fired = " + HHpar_ResWageChange_Fired + "\r\n" +
                                    "HHpar_ResWageChange_Unemployed = " + HHpar_ResWageChange_Unemployed + "\r\n" +
                                    "FIpar_Price_Change_Probability = " + FIpar_Price_Change_Probability + "\r\n" +
                                    "FIpar_Price_Change_Speed = " + FIpar_Price_Change_Speed + "\r\n" +
                                    "FIpar_Wage_Change_Probability = " + FIpar_Wage_Change_Probability + "\r\n" +
                                    "FIpar_Wage_Change_Speed = " + FIpar_Wage_Change_Speed + "\r\n" +
                                    "FIpar_Min_Inventory_Fraction = " + FIpar_Min_Inventory_Fraction + "\r\n" +
                                    "FIpar_Max_Inventory_Fraction = " + FIpar_Max_Inventory_Fraction + "\r\n" +
                                    "FIpar_Min_Profit = " + FIpar_Min_Profit + "\r\n" +
                                    "FIpar_Max_Profit = " + FIpar_Max_Profit + "\r\n"
                         ,false);

        DecimalFormat formatter = new DecimalFormat("0.000");

        for (int Month=0; Month<NumberOfMonths; Month++) {

            if (Month == ShockMonth) {
                My_Agents.Perform_Shock(1 + 0.05);
            }
            /*if (Month == 2182) {
                ResetRandomGenerator(RandomSeed_);
            }*/

            My_Agents.Plan_Actual_Month(Month);
            for (int Day=0; Day<21; Day++) {
                //Butterfly 2 shock
                if ((Day == 11) && (Month == ShockMonth)) {
                    //My_Agents.Get_Household(RandomGenerator.nextInt(NumberOfHH)).Set_MakeButterflySock(true);
                    //System.out.print("BF-Shock: ");
                }

                My_Agents.Perform_Day(Month, Day);

            }
            My_Agents.Perform_End_Of_Month(Month);
            My_Agents.Save_Actual_Money_Holding(Month, 21);
            My_Agents.Save_Data(Month);

            if (Silent==false) {
                System.out.print("Month: " + Month + " |  P = " + formatter.format(My_Agents.Get_PriceIndex(Month)) + "  W = " + formatter.format(My_Agents.Get_WageIndex(Month)) + "  Prod = " + formatter.format(My_Agents.Get_Aggr_Production(Month)) + "  D = " + formatter.format(My_Agents.Get_Aggr_Demand_Unsattisfied(Month)) +  "  I = " + formatter.format(My_Agents.Get_Aggr_Inventory(Month)) + "  E = " + formatter.format(My_Agents.Get_Employment(Month)));
                int Richest_HH = -1;
                double Money_Of_Richest = 0;
                for (int Counter=0; Counter<NumberOfHH; Counter++) {
                    if (My_Agents.Get_Household(Counter).Get_Money() > Money_Of_Richest) {
                        Money_Of_Richest = My_Agents.Get_Household(Counter).Get_Money();
                        Richest_HH = Counter;
                    }
                }
                System.out.print(" Richest HH = " + formatter.format(Richest_HH) + " his money = " + formatter.format(Money_Of_Richest) + "\r\n");
            }
            
        }

        My_Agents.Write_Compleat_Data_To_File();

    }

    void ResetRandomGenerator (int NewRandomSeed_) {
        RandomGenerator = new Random(NewRandomSeed_);
        My_Agents.ResetRandomSeed(RandomGenerator.nextInt());
    }
    
}









class ShutdownHook extends Thread {

/*    Agents My_Agents;

    void ShutdownHook(Agents My_Agents_) {
        My_Agents = My_Agents_;
    }   */

    io my_io;

    public ShutdownHook(io my_io_) {
        my_io = my_io_;
    }

    @Override public void run() {

        my_io.WriteToFile("Money_FI.m", "];", true);

        //Copy FreeMat Plotting routines into the folder
        my_io.copyFile("plot_results.m", my_io.Get_Folder()+"\\plot_results.m", 1000, true);
        my_io.copyFile("plot_results_2.m", my_io.Get_Folder()+"\\plot_results_2.m", 1000, true);
        my_io.copyFile("plot_results_article.m", my_io.Get_Folder()+"\\plot_results_article.m", 1000, true);
        my_io.copyFile("correlations_data", my_io.Get_Folder()+"\\correlations_data", 1000, true);
        my_io.copyFile("correlations_data_2", my_io.Get_Folder()+"\\correlations_data_2", 1000, true);
        my_io.copyFile("correlation_data_bootstrap_upper", my_io.Get_Folder()+"\\correlation_data_bootstrap_upper", 1000, true);
        my_io.copyFile("correlation_data_bootstrap_lower", my_io.Get_Folder()+"\\correlation_data_bootstrap_lower", 1000, true);
        my_io.copyFile("correlation_data_bootstrap_mean", my_io.Get_Folder()+"\\correlation_data_bootstrap_mean", 1000, true);

    }
}
