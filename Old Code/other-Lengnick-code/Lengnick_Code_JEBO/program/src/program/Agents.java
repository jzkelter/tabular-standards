package program;

import java.util.Random;

public class Agents {

    int NumberOfHH;
    int NumberOfFI;
    int NumberOfMonths;

    Household[] HH_List;
    Firm[] FI_List;

    Random RandomGenerator;

    io my_io;

    double[] PriceIndex;        //Vectors for saving results
    double[] PriceMax;
    double[] PriceMin;
    double[] WageIndex;
    double[] WageMax;
    double[] WageMin;
    double[] ResWageIndex;
    double[] Employment;
    double[] Aggr_Production;
    double[] Aggr_Inventory;
    double[][] FI_Inventory;
    double[][] FI_Profits;
    double[] Aggr_Profits;
    double[] Aggr_Sales;
    double[] Aggr_Demand_Planned;
    double[] Aggr_Demand_Unsattisfied;
    //double[] Aggr_Demand_double_Counted;     //Some demand is counted double by two firms. This happens if a HH demends at one firm, is restricted by the firms low inventory and then demends at another firm
    //double[] Aggr_SavingsQuote;
    double[] Aggr_Money;
    double[][] HH_Money;
    double[][] HH_Money_Aggr;
    double[][] FI_Size;
    double[][] FI_Money;
    double[][] FI_Money_Aggr;
    double[] Connection_Changes;      //Number of connections that have chaged the knodes
    double[][] FI_Strategy;
    int vacancies[];
    int[] CountEndOfPeriodWageCuts;    // Count how often the workers have to accept Wage cuts because of insufficient money of firms for every period
    double[][] Rel_EndOfPeriodWageCuts;   // and what is the relative amount of the cut
    
    public Agents(int NumberOfHH_, int NumberOfFI_, int RandomSeed, int NumberOfMonths_, io my_io_, int HHs_NumberOfConnections_A) {
        NumberOfHH = NumberOfHH_;
        NumberOfFI = NumberOfFI_;

        RandomGenerator = new Random(RandomSeed);

        my_io = my_io_;

        NumberOfMonths = NumberOfMonths_;
        PriceIndex = new double[NumberOfMonths];
        PriceMax = new double[NumberOfMonths];
        PriceMin = new double[NumberOfMonths];
        WageIndex = new double[NumberOfMonths];
        WageMax = new double[NumberOfMonths];
        WageMin = new double[NumberOfMonths];
        ResWageIndex = new double[NumberOfMonths];
        Employment = new double[NumberOfMonths];
        Aggr_Production = new double[NumberOfMonths];
        Aggr_Inventory = new double[NumberOfMonths];
        FI_Inventory = new double[NumberOfFI][NumberOfMonths];
        FI_Profits = new double[NumberOfFI][NumberOfMonths];
        Aggr_Profits = new double[NumberOfMonths];
        Aggr_Sales = new double[NumberOfMonths];
        Aggr_Demand_Planned = new double[NumberOfMonths];
        Aggr_Demand_Unsattisfied = new double[NumberOfMonths];
        //Aggr_Demand_double_Counted = new double[NumberOfMonths];
        Aggr_Money = new double[NumberOfMonths];
        //Aggr_SavingsQuote = new double[NumberOfMonths];
        FI_Size = new double[NumberOfFI][NumberOfMonths];
        FI_Money = new double[NumberOfFI][22];                  //One day more to also save money after paying wages and profits
        FI_Money_Aggr = new double[NumberOfMonths][22];         //One day more to also save money after paying wages and profits
        HH_Money = new double[NumberOfMonths][NumberOfHH];
        HH_Money_Aggr = new double[NumberOfMonths][22];         //One day more to also save money after paying wages and profits
        Connection_Changes = new double[NumberOfMonths];
        FI_Strategy = new double[NumberOfMonths][6];
        vacancies = new int[NumberOfMonths];
        CountEndOfPeriodWageCuts = new int[NumberOfMonths];
        Rel_EndOfPeriodWageCuts = new double[NumberOfMonths][NumberOfFI];
        
        FI_List = new Firm[NumberOfFI];
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter] = new Firm(RandomGenerator.nextInt(), NumberOfMonths, this, Counter);
        }
        HH_List = new Household[NumberOfHH];
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_List[Counter] = new Household(RandomGenerator.nextInt(), this, Counter, HHs_NumberOfConnections_A);
            boolean List_Not_Full = true;
            while(List_Not_Full) {
                List_Not_Full = HH_List[Counter].Add_Firm_To_Sublist(RandomGenerator.nextInt(NumberOfFI));
            }
            if (RandomGenerator.nextDouble() < 1-RandomGenerator.nextDouble()/50) {     //Create some initial unemployment. Make it random in order to have initial conditions across simulations different
                HH_List[Counter].Set_Employer(RandomGenerator.nextInt(NumberOfFI));
                FI_List[HH_List[Counter].Get_Employer()].Add_Worker(Counter);
            } else {
                HH_List[Counter].Set_Employer(-1);
            }
        }

    }

    void Set_HH_SavingsProgression(double value) {
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_List[Counter].Set_SavingsProgression(value);
        }
    }

    void Set_HH_ResWageChange_Fired(double value) {
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_List[Counter].Set_ResWageChange_Fired(value);
        }
    }
    void Set_HH_ResWageChange_Employed(double value) {
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_List[Counter].Set_ResWageChange_Employed(value);
        }
    }

    void Set_HH_ResWageChange_Unemployed(double value) {
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_List[Counter].Set_ResWageChange_Unemployed(value);
        }
    }

    void Set_FI_Price(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_Price(value);
        }
    }

    void Set_FI_Wage(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_Wage(value);
        }
    }

    void Set_FI_Price_Change_Probability(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_Price_Change_Probability(value);
        }
    }

    void Set_FI_Price_Change_Speed(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_Price_Change_Speed(value);
        }
    }

    void Set_FI_Wage_Change_Probability(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_Wage_Change_Probability(value);
        }
    }

    void Set_FI_Wage_Change_Speed(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_Wage_Change_Speed(value);
        }
    }

    void Set_FI_Min_Inventory_Fraction(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_Min_Inventory_Fraction(value);
        }
    }

    void Set_FI_Max_Inventory_Fraction(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_Max_Inventory_Fraction(value);
        }
    }

    void Set_FI_Min_Profit(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_Min_Profit(value);
        }
    }

    void Set_FI_Max_Profit(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_Max_Profit(value);
        }
    }

    void Set_FI_First_Month_Of_Planning(double value) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Set_First_Month_Of_Planning(value);
        }
    }

    int Get_NumberOfFI() {
        return NumberOfFI;
    }

    int Get_NumberOfHH() {
        return NumberOfHH;
    }

    Firm Get_Firm(int Firm_No_) {
        return FI_List[Firm_No_];
    }

    Household Get_Household(int HH_No_) {
        return HH_List[HH_No_];
    }

    double Get_PriceIndex(int Month_) {
        return PriceIndex[Month_];
    }

    double Get_WageIndex(int Month_) {
        return WageIndex[Month_];
    }

    double Get_Employment(int Month_) {
        return Employment[Month_];
    }

    double Get_Aggr_Production(int Month_) {
        return Aggr_Production[Month_];
    }

    double Get_Aggr_Inventory(int Month_) {
        return Aggr_Inventory[Month_];
    }

    double Get_Aggr_Sales(int Month_) {
        return Aggr_Sales[Month_];
    }

    double Get_Aggr_Demand_Unsattisfied(int Month_) {
        return Aggr_Demand_Unsattisfied[Month_];
    }

    //void Add_Aggr_Demand_double_Counted(int Month_, double value) {
    //    Aggr_Demand_double_Counted[Month_] = Aggr_Demand_double_Counted[Month_] + value;
    //}

    void Firm_Reports_Used_Strategy(int Month_, int strat) {
        FI_Strategy[Month_][strat] = FI_Strategy[Month_][strat] + 1;
    }

    double Get_Aggr_Money(int Month_) {
        return Aggr_Money[Month_];
    }
    
    void Report_EndOfPeriodWageCut(int Month_, int FI_No_, double Rel_WageCut_) {
        CountEndOfPeriodWageCuts[Month_]++;
        Rel_EndOfPeriodWageCuts[Month_][FI_No_] = Rel_WageCut_;
    }

    void Plan_Actual_Month(int Month_) {
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Plan_Current_Month(Month_);
        }

        int[] Shuffeled_Firm_List = new int[NumberOfHH];
        int RND_HH_1;
        int RND_HH_2;
        int Merker;
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            Shuffeled_Firm_List[Counter] = Counter;
        }
        for (int Counter=0; Counter<2*NumberOfHH; Counter++) {
            RND_HH_1 = RandomGenerator.nextInt(NumberOfHH);
            RND_HH_2 = RandomGenerator.nextInt(NumberOfHH);
            Merker = Shuffeled_Firm_List[RND_HH_1];
            Shuffeled_Firm_List[RND_HH_1] = Shuffeled_Firm_List[RND_HH_2];
            Shuffeled_Firm_List[RND_HH_2] = Merker;
        }
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_List[Counter].Plan_Next_Month(Month_);
            Aggr_Demand_Planned[Month_] = Aggr_Demand_Planned[Month_] + HH_List[Counter].Get_Real_Daily_Demand();
        }

    }

    void Perform_Day(int Month_, int Day_) {

        int[] Shuffeled_Firm_List = new int[NumberOfHH];
        int RND_HH_1;
        int RND_HH_2;
        int Merker;
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            Shuffeled_Firm_List[Counter] = Counter;
        }
        for (int Counter=0; Counter<2*NumberOfHH; Counter++) {
            RND_HH_1 = RandomGenerator.nextInt(NumberOfHH);
            RND_HH_2 = RandomGenerator.nextInt(NumberOfHH);
            Merker = Shuffeled_Firm_List[RND_HH_1];
            Shuffeled_Firm_List[RND_HH_1] = Shuffeled_Firm_List[RND_HH_2];
            Shuffeled_Firm_List[RND_HH_2] = Merker;
        }
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_List[Shuffeled_Firm_List[Counter]].Perform_Day(Month_, Day_);
        }


        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Perform_Day(Month_, Day_);
        }

        Save_Actual_Money_Holding(Month_, Day_);

    }


    void Save_Actual_Money_Holding(int Month_, int Day_) {
        FI_Money_Aggr[Month_][Day_] = 0;
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_Money[Counter][Day_] = FI_List[Counter].Get_Money();
            FI_Money_Aggr[Month_][Day_] = FI_Money_Aggr[Month_][Day_] + FI_List[Counter].Get_Money();
        }
        HH_Money_Aggr[Month_][Day_] = 0;
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_Money_Aggr[Month_][Day_] = HH_Money_Aggr[Month_][Day_] + HH_List[Counter].Get_Money();
        }
    }

    void Perform_End_Of_Month(int Month_) {
        double prod = 0;
        double inv = 0;
        double prof = 0;
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].PayProfits(Month_);
        }
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Perform_End_Of_Month(Month_);
            prod = prod + FI_List[Counter].Get_Production(Month_);
            inv = inv + FI_List[Counter].Get_Inventory();
            FI_Inventory[Counter][Month_] = FI_List[Counter].Get_Inventory();
            FI_Profits[Counter][Month_] = FI_List[Counter].Get_Last_Profits();
            prof = prof + FI_Profits[Counter][Month_];
        }
        Aggr_Production[Month_] = prod;
        Aggr_Inventory[Month_] = inv;
        Aggr_Profits[Month_] = prof;
    }

    void Save_Data(int Month_) {

        // Save Price Index
        double PI = 0;      //Price Index
        double WI = 0;      //Wage Index
        PriceMax[Month_] = 1E-10;
        PriceMin[Month_] = 1E10;
        WageMax[Month_] = 1E-10;
        WageMin[Month_] = 1E10;
        vacancies[Month_] = 0;

        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            PI = PI + FI_List[Counter].Get_Price()/NumberOfFI;
            WI = WI + FI_List[Counter].Get_Wage()/NumberOfFI;
            if (FI_List[Counter].Get_Price() > PriceMax[Month_]) {
                PriceMax[Month_] = FI_List[Counter].Get_Price();
            }
            if (FI_List[Counter].Get_Price() < PriceMin[Month_]) {
                PriceMin[Month_] = FI_List[Counter].Get_Price();
            }
            if (FI_List[Counter].Get_Wage() > WageMax[Month_]) {
                WageMax[Month_] = FI_List[Counter].Get_Wage();
            }
            if (FI_List[Counter].Get_Wage() < WageMin[Month_]) {
                WageMin[Month_] = FI_List[Counter].Get_Wage();
            }
            if (FI_List[Counter].IsJobFree()) {
                vacancies[Month_] ++;
            }
            //FI_Size[Counter][Month_] = FI_List[Counter].Get_NumberOfWorkers();
            //FI_Size[Counter][Month_] = FI_List[Counter].Get_Sales(Month_);
            FI_Size[Counter][Month_] = FI_List[Counter].Get_Demand(Month_);
        }
        PriceIndex[Month_] = PI;
        WageIndex[Month_] = WI;

        // Save Employment & ResWageIndex
        int Empl = 0;       //Employment of HHs
        ResWageIndex[Month_] = 0;
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            if (HH_List[Counter].Get_Employer() > -1) {
                Empl++;
            }
            ResWageIndex[Month_] = ResWageIndex[Month_] + HH_List[Counter].Get_Reservation_Wage()/NumberOfHH;
        }
        int Empl2 = 0;       //Employment of FIs
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            Empl2 = Empl2 + FI_List[Counter].NumberOfWorkers;
        }
        Employment[Month_] = Empl;
        if (Empl!=Empl2) {
            System.out.print("Error: Employmend of HHs is unequal employment of FIs!");
        }

        double prod = 0;          //Save production
        double sal = 0;           //Save Sales
        double mon = 0;           //Save Money Amount
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            prod = prod + FI_List[Counter].Get_Production(Month_);
            sal = sal + FI_List[Counter].Get_Sales(Month_);
            mon = mon + FI_List[Counter].Get_Money();
        }
        Aggr_Sales[Month_] = sal;

        
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            mon = mon + HH_List[Counter].Get_Money();
        }
        Aggr_Money[Month_] = mon;

        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_Money[Month_][Counter] = HH_List[Counter].Get_Money();
        }

        Write_Monthly_Data_To_File(Month_);
    }

    void Write_Compleat_Data_To_File() {
        //Aggr Employment
        my_io.Open_File_For_Writing("Employment.m", false);
        my_io.Write_To_Open_File("Employment = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(Employment[Counter] + ", ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        //Aggr Production
        my_io.Open_File_For_Writing("Aggr_Production.m", false);
        my_io.Write_To_Open_File("Aggr_Production = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(Aggr_Production[Counter] + ", ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        //Aggr Sales
        my_io.Open_File_For_Writing("Aggr_Sales.m", false);
        my_io.Write_To_Open_File("Aggr_Sales = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(Aggr_Sales[Counter] + ", ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        //Aggr Profits
        my_io.Open_File_For_Writing("Aggr_Profits.m", false);
        my_io.Write_To_Open_File("Aggr_Profits = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(Aggr_Profits[Counter] + ", ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        //Aggr Demand Planned
        my_io.Open_File_For_Writing("Aggr_Demand_PlannedDaily.m", false);
        my_io.Write_To_Open_File("Aggr_Demand_Planned = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(Aggr_Demand_Planned[Counter] + ", ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        //Aggr Demand Unsattisfied
        my_io.Open_File_For_Writing("Aggr_Demand_Unsattisfied.m", false);
        my_io.Write_To_Open_File("Aggr_Demand_Unsattisfied = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(Aggr_Demand_Unsattisfied[Counter] + ", ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        //Price Index
        my_io.Open_File_For_Writing("PriceIndex.m", false);
        my_io.Write_To_Open_File("PriceIndex = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(PriceIndex[Counter]+","+PriceMax[Counter]+","+PriceMin[Counter]+";  ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        //Individual Firms Size
        /*my_io.Open_File_For_Writing("FI_Size.m", false);
        my_io.Write_To_Open_File("FI_Size = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            for (int Counter2=0; Counter2<NumberOfFI; Counter2++) {
                my_io.Write_To_Open_File(FI_Size[Counter2][Counter]+" ");
            }
            my_io.Write_To_Open_File(";\r\n");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();        creates large files  */

        //Wage Index
        my_io.Open_File_For_Writing("WageIndex.m", false);
        my_io.Write_To_Open_File("WageIndex = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(WageIndex[Counter]+","+WageMax[Counter]+","+WageMin[Counter]+","+ResWageIndex[Counter]+";  ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();
    
        //ConnectionChanges
        my_io.Open_File_For_Writing("Connection_Changes.m", false);
        my_io.Write_To_Open_File("Connection_Changes = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(Connection_Changes[Counter] + ", ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        //Firms Strategy
        my_io.Open_File_For_Writing("FI_Strategy.m", false);
        my_io.Write_To_Open_File("FI_Strategy = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(FI_Strategy[Counter][0] + "," + FI_Strategy[Counter][1] + "," + FI_Strategy[Counter][2] + "," + FI_Strategy[Counter][3] + "," + FI_Strategy[Counter][4] + "," + FI_Strategy[Counter][5] + ";");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        //Vacancies
        my_io.Open_File_For_Writing("Vacancies.m", false);
        my_io.Write_To_Open_File("Vacancies = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(vacancies[Counter] + ", ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        //Aggregat Money
        my_io.Open_File_For_Writing("Aggr_Money.m", false);
        my_io.Write_To_Open_File("Aggr_Money = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(Aggr_Money[Counter] + ", ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();
        
  /*      //Individual Firms Inventory
        my_io.Open_File_For_Writing("FI_Inventory.m", true);
        my_io.Write_To_Open_File("FI_Inventory = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            for (int Counter2=0; Counter2<NumberOfFI; Counter2++) {
                my_io.Write_To_Open_File(FI_Inventory[Counter2][Counter] + " ");
            }
            my_io.Write_To_Open_File(";\r\n");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();      Creates big files   */

        //Aggregat Firms Inventory
/*        my_io.Open_File_For_Writing("Aggr_Inventory.m", true);
        my_io.Write_To_Open_File("Aggr_Inventory = [");
        double sum;
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            sum = 0;
            for (int Counter2=0; Counter2<NumberOfFI; Counter2++) {
                sum = sum + FI_Inventory[Counter2][Counter];
            }
            my_io.Write_To_Open_File(sum + " ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();    creates large files */

        //Individual Firms Profits
        /*my_io.Open_File_For_Writing("FI_Profits.m", false);
        my_io.Write_To_Open_File("FI_Profits = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            for (int Counter2=0; Counter2<NumberOfFI; Counter2++) {
                my_io.Write_To_Open_File(FI_Profits[Counter2][Counter] + ", ");
            }
            my_io.Write_To_Open_File(";\r\n");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();        creates large files  */

        // Individual Money
        my_io.Open_File_For_Writing("Money_FI_Mean.m", false);
        my_io.Write_To_Open_File("Money_FI_Mean = [");
        for (int Counter_Month=0; Counter_Month<NumberOfMonths; Counter_Month++) {
            for (int Counter_Day=0; Counter_Day<22; Counter_Day++) {
                my_io.Write_To_Open_File(FI_Money_Aggr[Counter_Month][Counter_Day] + ", ");
            }
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        my_io.Open_File_For_Writing("Money_HH_Mean.m", false);
        my_io.Write_To_Open_File("Money_HH_Mean = [");
        for (int Counter_Month=0; Counter_Month<NumberOfMonths; Counter_Month++) {
            for (int Counter_Day=0; Counter_Day<22; Counter_Day++) {
                my_io.Write_To_Open_File(HH_Money_Aggr[Counter_Month][Counter_Day]+", ");
            }
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File(); 

  /*      my_io.Open_File_For_Writing("Money_HH.m", false);
        my_io.Write_To_Open_File("Money_HH = [");
        for (int Counter_Month=0; Counter_Month<NumberOfMonths; Counter_Month++) {
            for (int Counter_HH=0; Counter_HH<NumberOfHH; Counter_HH++) {
                my_io.Write_To_Open_File(HH_Money[Counter_Month][Counter_HH]+", ");
            }
            my_io.Write_To_Open_File(" ; ");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();      Creates big files   */

        //CountEndOfPeriodWageCuts
        my_io.Open_File_For_Writing("CountEndOfPeriodWageCuts.m", false);
        my_io.Write_To_Open_File("CountEndOfPeriodWageCuts = [");
        for (int Counter=0; Counter<NumberOfMonths; Counter++) {
            my_io.Write_To_Open_File(CountEndOfPeriodWageCuts[Counter] + ";");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();

        my_io.Open_File_For_Writing("Rel_EndOfPeriodWageCuts.m", false);
        my_io.Write_To_Open_File("Rel_EndOfPeriodWageCuts = [");
        for (int Counter_Month=0; Counter_Month<NumberOfMonths; Counter_Month++) {
            for (int Counter_FI=0; Counter_FI<NumberOfFI; Counter_FI++) {
                my_io.Write_To_Open_File(Rel_EndOfPeriodWageCuts[Counter_Month][Counter_FI]+", ");
            }
            my_io.Write_To_Open_File(";\r\n");
        }
        my_io.Write_To_Open_File("];");
        my_io.Close_Open_File();         
    }

    void Write_Monthly_Data_To_File(int Month_) {
        if (Month_==0) {
            my_io.WriteToFile("Money_FI.m", "Money_FI = [", false);
            my_io.WriteToFile("Money_HH.m", "Money_HH = [", false);

        }



        //Individual Firm Price and Demand Correlation , Inventories
        if (Month_ >= 800000) {
            my_io.WriteToFile("P_D_Corr.m", "P_D_Corr = [", false);
            my_io.WriteToFile("P_I_Corr.m", "P_I_Corr = [", false);
            for (int Counter=0; Counter<NumberOfFI; Counter++) {
                my_io.WriteToFile("P_D_Corr.m", FI_List[Counter].Get_Demand(Month_) + "," + FI_List[Counter].Get_Price() + ";  ", true);
                my_io.WriteToFile("P_I_Corr.m", FI_List[Counter].Get_Inventory() + "," + FI_List[Counter].Get_Price() + ";  ", true);
            }
            my_io.WriteToFile("P_D_Corr.m", "];", true);
            my_io.WriteToFile("P_I_Corr.m", "];", true);
        }



        /*String stri = "";
        for (int Counter_Day=20; Counter_Day<21; Counter_Day++) {
            for (int Counter_FI=0; Counter_FI<NumberOfFI; Counter_FI++) {
                stri = stri + FI_Money[Counter_FI][Counter_Day]+", ";
            }
            stri = stri + ";";
        }
        my_io.WriteToFile("Money_FI.m", stri, true);

        my_io.WriteToFile("Money_FI.m", ";\r\n", true);  */

    }

    void Add_Aggr_Demand_Unsattisfied(double value, int Month_) {
        Aggr_Demand_Unsattisfied[Month_] = Aggr_Demand_Unsattisfied[Month_] + value;
    }

    void ReportOneConnectionChage(int Month_) {
        Connection_Changes[Month_]++;
    }

    void Perform_Shock(double value) {
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_List[Counter].Shock(value);
        }
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].Shock(value);
        }
    }
    
    void ResetRandomSeed(int RandomSeed_) {
        RandomGenerator = new Random(RandomSeed_);
        for (int Counter=0; Counter<NumberOfHH; Counter++) {
            HH_List[Counter].ResetRandomSeed(RandomGenerator.nextInt());
        }
        for (int Counter=0; Counter<NumberOfFI; Counter++) {
            FI_List[Counter].ResetRandomSeed(RandomGenerator.nextInt());
        }
    }

}
