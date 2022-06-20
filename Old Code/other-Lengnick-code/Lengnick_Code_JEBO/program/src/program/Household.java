package program;

import java.util.Random;

public class Household {

    double Money = 98.78;
    int Employer;
    int[] SubList_Of_Firms;     //Firms the HH buyes from
    double[] Firms_Restricted;     //Remember wich firms did not have enough goods
    double[] Firms_Restricted_Cumm;     //  ''  Cummulated

    double SavingsProgression;
    double ReservationWage = 0;
    double ResWageChange_Fired;
    double ResWageChange_Unemployed;
    double ResWageChange_Employed;
    int No_Of_Firms_To_Aks_For_Job = 5;

    //Plans
    double Real_Daily_Demand;
    double[] Choose_Firm_Probs_Cumm;    //Commulated probability of choosing firm in sublist

    Random RandomGenerator;
    Agents My_Agents;           //The My_Agents Object holds information of all agents
    int MyHHNumber;             //Which is the identification number of this Household

    boolean MakeButterflySock = false;

    public Household(int RandomSeed, Agents My_Agents_, int MyHHNumber_, int NumberOfConnections_A) {
        RandomGenerator = new Random(RandomSeed);
        My_Agents = My_Agents_;
        MyHHNumber = MyHHNumber_;

        SubList_Of_Firms = new int[NumberOfConnections_A];
        Firms_Restricted = new double[NumberOfConnections_A];
        Firms_Restricted_Cumm = new double[NumberOfConnections_A];
        Choose_Firm_Probs_Cumm = new double[SubList_Of_Firms.length];
        
        for (int Counter=0; Counter<SubList_Of_Firms.length; Counter++) {
            SubList_Of_Firms[Counter] = -1;
        }
    }

    void Set_SavingsProgression(double value) {
        SavingsProgression = value;
    }

    void Set_ResWageChange_Employed(double value) {
        ResWageChange_Employed = value;
    }

    void Set_ResWageChange_Fired(double value) {
        ResWageChange_Fired = value;
    }

    void Set_ResWageChange_Unemployed(double value) {
        ResWageChange_Unemployed = value;
    }

    void Set_MakeButterflySock(boolean value) {
        MakeButterflySock = value;
    }

    double Get_Money() {
        return Money;
    }

    double Get_Reservation_Wage() {
        return ReservationWage;
    }

    double Get_Real_Daily_Demand() {
        return Real_Daily_Demand;
    }

    void Raise_Money(double value) {
        Money = Money + value;
    }

    boolean Is_Firm_In_List(int No_Of_Firm) {
        for (int Counter=0; Counter<SubList_Of_Firms.length; Counter++) {
            if (SubList_Of_Firms[Counter]==No_Of_Firm) {
                return true;
            }
        }
        return false;
    }

    boolean Add_Firm_To_Sublist(int FI_Number_) {
        for (int Counter=0; Counter<SubList_Of_Firms.length; Counter++) {
            if (SubList_Of_Firms[Counter]==FI_Number_) {   //Firm is already in list
                return true;
            }
            if (SubList_Of_Firms[Counter]==-1) {
                SubList_Of_Firms[Counter] = FI_Number_;
                Counter = SubList_Of_Firms.length;
            }
        }
        
        if (SubList_Of_Firms[SubList_Of_Firms.length-1] == -1) {
            return true;
        } else {
            return false;
        }
    }

    void Set_Employer(int Firm_No_) {
        Employer = Firm_No_;
    }

    int Get_Employer() {
        return Employer;
    }

    void Plan_Next_Month(int Month_) {

        int Firm_Added_In_First_Selection = -1;
        if (RandomGenerator.nextDouble()<0.25) {
        //Check if there is a cheaper firm not in the list

            double[] Firms_Size_Cumm = new double[My_Agents.NumberOfFI];
            Firms_Size_Cumm[0] = My_Agents.Get_Firm(0).Get_NumberOfWorkers();
            for (int Counter=1; Counter<My_Agents.NumberOfFI; Counter++) {
                Firms_Size_Cumm[Counter] = Firms_Size_Cumm[Counter-1] + My_Agents.Get_Firm(Counter).Get_NumberOfWorkers();
            }
            for (int Counter=0; Counter<My_Agents.NumberOfFI; Counter++) {
                Firms_Size_Cumm[Counter] = Firms_Size_Cumm[Counter] / Firms_Size_Cumm[My_Agents.NumberOfFI-1];
            }

            int RND_Firm_From_List_Pos = RandomGenerator.nextInt(SubList_Of_Firms.length);
            int RND_Firm_From_List = SubList_Of_Firms[RND_Firm_From_List_Pos];
            int RND_Firm_Not_In_List = -1;
            double RND;
            do {
                RND = RandomGenerator.nextDouble();
                for (int Counter=0; Counter<My_Agents.NumberOfFI; Counter++) {
                    if (RND < Firms_Size_Cumm[Counter]) {
                        RND_Firm_Not_In_List = Counter;
                        break;
                    }
                }
            } while (Is_Firm_In_List(RND_Firm_Not_In_List) == true);
            if (My_Agents.Get_Firm(RND_Firm_From_List).Get_Price()*0.99 > My_Agents.Get_Firm(RND_Firm_Not_In_List).Get_Price()) {
                SubList_Of_Firms[RND_Firm_From_List_Pos] = RND_Firm_Not_In_List;
                My_Agents.ReportOneConnectionChage(Month_);
                Firm_Added_In_First_Selection = SubList_Of_Firms[RND_Firm_From_List_Pos];
            }
        }
        if (RandomGenerator.nextDouble()<0.25) {
        //Replace a firm that restricted me
            Firms_Restricted_Cumm[0] = Firms_Restricted[0];
            for (int Counter=1; Counter<SubList_Of_Firms.length; Counter++) {
                Firms_Restricted_Cumm[Counter] = Firms_Restricted_Cumm[Counter-1] + Firms_Restricted[Counter];
            }
            if (Firms_Restricted_Cumm[SubList_Of_Firms.length-1] > 0) {
                for (int Counter=0; Counter<SubList_Of_Firms.length; Counter++) {
                    Firms_Restricted_Cumm[Counter] = Firms_Restricted_Cumm[Counter] / Firms_Restricted_Cumm[SubList_Of_Firms.length-1];
                }
                int Firm_From_List_Pos = -1;
                double RND = RandomGenerator.nextDouble();
                for (int Counter=0; Counter<SubList_Of_Firms.length; Counter++) {
                    if (RND < Firms_Restricted_Cumm[Counter]) {
                        Firm_From_List_Pos = Counter;
                        break;
                    }
                }
                int RND_Firm_Not_In_List = -1;
                while (true) {
                    RND_Firm_Not_In_List = RandomGenerator.nextInt(My_Agents.Get_NumberOfFI());
                    if ( (Is_Firm_In_List(RND_Firm_Not_In_List) == false) && (RND_Firm_Not_In_List!=Firm_Added_In_First_Selection) ) {  //FI is not in sublist and not removed during price selection above
                        break;
                    }
                }

                SubList_Of_Firms[Firm_From_List_Pos] = RND_Firm_Not_In_List;        //Make the change
            }
        }
        //Clear "Firms_Restricted"
        Firms_Restricted = new double[Firms_Restricted.length];

        
        // ----- If Unemployed: Look for Work -----
        int reminder, RND1, RND2;
        if ( (Employer == -1) ) {
            //Create Random List of all Firms
            int Random_Firm_List[] = new int[My_Agents.Get_NumberOfFI()];
            for (int Counter=0; Counter<My_Agents.Get_NumberOfFI(); Counter++) {
                Random_Firm_List[Counter] = Counter;
            }
            //Shuffel that list
            for (int Counter=0; Counter<Random_Firm_List.length*3; Counter++) {
                RND1 = RandomGenerator.nextInt(Random_Firm_List.length);
                RND2 = RandomGenerator.nextInt(Random_Firm_List.length);
                reminder = Random_Firm_List[RND1];
                Random_Firm_List[RND1] = Random_Firm_List[RND2];
                Random_Firm_List[RND2] = reminder;
            }
            //Ask the first "No_Of_Firms_To_Aks_For_Job" Firms in list if job is free
            for (int Counter=0; Counter<No_Of_Firms_To_Aks_For_Job; Counter++) {
                if ( (My_Agents.Get_Firm(Random_Firm_List[Counter]).IsJobFree()) && (My_Agents.Get_Firm(Random_Firm_List[Counter]).Get_Wage()>ReservationWage) ) {
                    Set_Employer(Random_Firm_List[Counter]);
                    My_Agents.Get_Firm(Random_Firm_List[Counter]).Add_Worker(MyHHNumber);
                    My_Agents.ReportOneConnectionChage(Month_);
                    Counter = Random_Firm_List.length;   // Don't search any further
                }
            }
            if (Employer == -1) {
                ReservationWage = ReservationWage * ResWageChange_Unemployed;
            }
        } else {  // ----- If Employed: Look for better payed job -----
            if ( My_Agents.Get_Firm(Employer).Get_NumberOfWorkers()>1) {  //Last worker does not quit
                if ( (RandomGenerator.nextDouble()<0.1) || (My_Agents.Get_Firm(Employer).Get_Wage()<ReservationWage) ) {
                    int FI_to_look_at = Employer;    //Set an incorrect value ...
                    do {
                        FI_to_look_at = RandomGenerator.nextInt(My_Agents.Get_NumberOfFI());   // ... and redraw until correct
                    } while (FI_to_look_at == Employer);
                    if ( (My_Agents.Get_Firm(FI_to_look_at).IsJobFree()) && (My_Agents.Get_Firm(FI_to_look_at).Get_Wage() > My_Agents.Get_Firm(Employer).Get_Wage()) && (My_Agents.Get_Firm(FI_to_look_at).Get_Wage() > ReservationWage) ) {
                        My_Agents.Get_Firm(Employer).I_Quit(MyHHNumber);
                        My_Agents.Get_Firm(FI_to_look_at).Add_Worker(MyHHNumber);
                        Employer = FI_to_look_at;
                        My_Agents.ReportOneConnectionChage(Month_);
                    }
                }
                ReservationWage = ReservationWage * ResWageChange_Employed;
            }
        }



    // ----- Consumption -----
        //Calculate personal price index
        double P_I = 0;
        for (int Counter=0; Counter<SubList_Of_Firms.length; Counter++) {
            P_I = P_I + My_Agents.Get_Firm(SubList_Of_Firms[Counter]).Get_Price()/SubList_Of_Firms.length;
        }

        double Min_P = 1E100;
        double Max_P = 0;
        for (int Counter=0; Counter<SubList_Of_Firms.length; Counter++) {
            if (Min_P > My_Agents.Get_Firm(SubList_Of_Firms[Counter]).Get_Price()) {
                Min_P = My_Agents.Get_Firm(SubList_Of_Firms[Counter]).Get_Price();
            }
            if (Max_P < My_Agents.Get_Firm(SubList_Of_Firms[Counter]).Get_Price()) {
                Max_P = My_Agents.Get_Firm(SubList_Of_Firms[Counter]).Get_Price();
            }
        }

        //Devide Money in consumption and savings
        double Money_for_Consumption = Math.min(  P_I * Math.pow( Math.max(Money,0)/P_I , SavingsProgression )  ,  Money  );
        Real_Daily_Demand = Money_for_Consumption/21/P_I;

        //Calculate Probalities of choosing firms to buy from
        double[] Probs = new double[SubList_Of_Firms.length];
        double Probs_sum = 0;
        for (int Counter=0; Counter<SubList_Of_Firms.length; Counter++) {
            //Probs[Counter] = 1 /( My_Agents.Get_Firm(SubList_Of_Firms[Counter]).Get_Price() - 0.975*Min_P );
            //Probs[Counter] = 1.1*Max_P - My_Agents.Get_Firm(SubList_Of_Firms[Counter]).Get_Price();
            Probs[Counter] = 1;
            Probs_sum = Probs_sum + Probs[Counter];
        }

        Choose_Firm_Probs_Cumm[0] = Probs[0]/Probs_sum;
        for (int Counter=1; Counter<SubList_Of_Firms.length-1; Counter++) {
            Choose_Firm_Probs_Cumm[Counter] = Choose_Firm_Probs_Cumm[Counter-1] + Probs[Counter]/Probs_sum;
        }
        Choose_Firm_Probs_Cumm[SubList_Of_Firms.length-1] = 1;

    }

    void Perform_Day(int Month_, int Day_) {
    // --- Buy Goods ---
        double Remeining_Demand = Real_Daily_Demand;
        if (MakeButterflySock) {
            System.out.print(Remeining_Demand + " --> ");
            Remeining_Demand = Remeining_Demand*0.95;
            System.out.print(Remeining_Demand + "");
        }
        boolean[] Already_Bought_From = new boolean[SubList_Of_Firms.length];     //Remember wich firms did not have enough goods

        for (int Counter2=1; Counter2<=SubList_Of_Firms.length; Counter2++) {
            
            // find a random firm from the sublist. Probability of picking firm f is taken from Choose_Firm_Probs_Cumm
            double RND;
            int Firm_No_in_Sublist = -1;
            do {
                RND = RandomGenerator.nextDouble();
                for (int Counter=0; Counter<SubList_Of_Firms.length; Counter++) {
                    if (RND < Choose_Firm_Probs_Cumm[Counter]) {
                        Firm_No_in_Sublist = Counter;
                        break;
                    }
                }
            } while (Already_Bought_From[Firm_No_in_Sublist]);  
            int Firm_No = SubList_Of_Firms[Firm_No_in_Sublist];

            double Price = My_Agents.Get_Firm(Firm_No).Get_Price();
            Already_Bought_From[Firm_No_in_Sublist] = true;    // this firm should never be picked again for buying
            // check if household can afford
            double Goods_To_Buy = Math.min(  Remeining_Demand  ,  Money/Price  );
            My_Agents.Get_Firm(Firm_No).Report_Demand(Goods_To_Buy, Month_);
            // check if firm has enough inventory:
            double Goods_To_Buy_2 = Math.min(  Goods_To_Buy  ,  My_Agents.Get_Firm(Firm_No).Get_Inventory()  );
            //Remeining_Demand = Goods_To_Buy - Goods_To_Buy_2;         //How much goods can not be bought because of low inventory
            Remeining_Demand = Remeining_Demand - Goods_To_Buy_2;         //How much goods can not be bought because of low inventory
            // perform the exchange
            Money = Money - Goods_To_Buy_2*Price;
            My_Agents.Get_Firm(Firm_No).HH_Buyes_Goods(Goods_To_Buy_2, Month_);

            if (Remeining_Demand > 1E-10) {
                Firms_Restricted[Firm_No_in_Sublist] = Firms_Restricted[Firm_No_in_Sublist] + Remeining_Demand;
            }
            if ( (Remeining_Demand < 0.05*Real_Daily_Demand) || (Money < 1E-10) ){
                break;
            } else {
                int stop = 1;
            }
        }

        if (Remeining_Demand > 1E-10) {
            My_Agents.Add_Aggr_Demand_Unsattisfied(Remeining_Demand, Month_);
        }

        if (MakeButterflySock) {
            System.out.println("  Remaining Demand: " + Remeining_Demand);
            MakeButterflySock = false;
        }
        
    }

    void Firm_Payes_Wage(double Amount) {
        Money = Money + Amount;
        if (Amount > ReservationWage) {
            ReservationWage = Amount;
        }
    }

    void YouAreFired() {      //The firm fires the household  :-(
        Employer = -1;
        ReservationWage = ReservationWage * ResWageChange_Fired;
    }

    void Shock(double value) {      //Perform some exogenous shock

    //Make one reconnection
        //int new_Random_firm;
        //do {
        //    new_Random_firm = RandomGenerator.nextInt(SubList_Of_Firms.length);
        //} while (Is_Firm_In_List(new_Random_firm));
        //SubList_Of_Firms[RandomGenerator.nextInt(SubList_Of_Firms.length)] = new_Random_firm;
        
    //Raise money amount
        Money = Money * value;
    }

    void ResetRandomSeed (int RandomSeed_) {
        RandomGenerator = new Random(RandomSeed_);
    }
    
}
