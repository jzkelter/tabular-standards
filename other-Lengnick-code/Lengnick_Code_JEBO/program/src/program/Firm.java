package program;

import java.util.Random;

public class Firm {

    int NumberOfMonths;
    Agents My_Agents;
    Random RandomGenerator;
    int MyFINumber;

    double Money = 0;
    double Inventory = 50;      //Current Inventory
    double Price;
    double Wage;
    int[] Workers_List = new int[400];   //Last entry could not by used due to void "Remove_Worker"
    int NumberOfWorkers;                //How much workers are employed 
    int EmploymentTarget;
    boolean[] EmploymentTarget_Fullfilled;
    boolean Fire_Worker;
    boolean Hire_Worker;

    double Technology_Parameter = 3;
    double Wage_Change_Speed;
    double Wage_Change_Probability;
    double Price_Change_Speed;
    double Price_Change_Probability;
    double Min_Inventory_Fraction;
    double Max_Inventory_Fraction;
    double Min_Profit;
    double Max_Profit;
    double First_Month_Of_Planning;     //To make initial conditions across simulations different, firms start planning in different periods (minimum: 24)

    double[] Production;     //Vectors for saving the Results
    double[] Sales;
    double[] Demand;
    double[] Inventory_Daily;    // Inventory before new Production
    double Profits;     //Last payed out profits

    public Firm(int RandomSeed, int NumberOfMonths_, Agents My_Agents_, int MyFINumber_) {
        NumberOfMonths = NumberOfMonths_;
        My_Agents = My_Agents_;
        MyFINumber = MyFINumber_;
        RandomGenerator = new Random(RandomSeed);

        Production = new double[NumberOfMonths];
        Sales = new double[NumberOfMonths];
        Demand = new double[NumberOfMonths];
        Inventory_Daily = new double[21];
        EmploymentTarget_Fullfilled = new boolean[NumberOfMonths];
        for (int Counter=0; Counter<Workers_List.length; Counter++) {
            Workers_List[Counter] = -1;
        }
    }

    void Set_Price(double value) {
        Price = value;
    }

    void Set_Wage(double value) {
        Wage = value;
    }

    void Set_Price_Change_Probability(double value) {
        Price_Change_Probability = value;
    }

    void Set_Price_Change_Speed(double value) {
        Price_Change_Speed = value;
    }

    void Set_Wage_Change_Probability(double value) {
        Wage_Change_Probability = value;
    }

    void Set_Wage_Change_Speed(double value) {
        Wage_Change_Speed = value;
    }

    void Set_Min_Inventory_Fraction(double value) {
        Min_Inventory_Fraction = value;
    }

    void Set_Max_Inventory_Fraction(double value) {
        Max_Inventory_Fraction = value;
    }

    void Set_Min_Profit(double value) {
        Min_Profit = value;
    }

    void Set_Max_Profit(double value) {
        Max_Profit = value;
    }

    void Set_First_Month_Of_Planning(double value) {
        First_Month_Of_Planning = value;
    }

    double Get_Price() {
        return Price;
    }

    double Get_Wage() {
        return Wage;
    }

    double Get_Money() {
        return Money;
    }

    void Add_Money(double value) {
        Money = Money + value;
    }

    double Get_Inventory() {
        return Inventory;
    }

    double Get_Last_Profits() {
        return Profits;
    }

    void Add_Inventory(double value) {
        Inventory = Inventory + value;
    }

    double Get_Production(int Month_) {
        return Production[Month_];
    }

    double Get_Sales(int Month_) {
        return Sales[Month_];
    }

    double Get_Demand(int Month_) {
        return Demand[Month_];
    }

    void Report_Demand(double value, int Month_) {
        //Household reports how much goods he would buy if he is not constraind by low inventory
        Demand[Month_] = Demand[Month_] + value;
    }

    int Get_NumberOfWorkers() {
        return NumberOfWorkers;
    }

    void Add_Worker(int HH_Number_) {
        for (int Counter=0; Counter<Workers_List.length; Counter++) {
            if (Workers_List[Counter]==-1) {
                Workers_List[Counter] = HH_Number_;
                NumberOfWorkers = Counter+1;
                Counter = Workers_List.length;
            }
        }
    }

    void I_Quit(int HH_Number_) {   //HH reports that he quits
        for (int Counter=0; Counter<NumberOfWorkers; Counter++) {
            if (Workers_List[Counter]==HH_Number_) {
                Remove_Worker(Counter);
                Counter = NumberOfWorkers;
            }
        }
    }

    void Remove_Worker(int No_in_List) {
        if (No_in_List>=NumberOfWorkers) {
            No_in_List = NumberOfWorkers - 1;
        }
        My_Agents.Get_Household(Workers_List[No_in_List]).YouAreFired();   //Tell HH that he is fired
        for (int Counter=No_in_List; Counter<NumberOfWorkers; Counter++) {
            Workers_List[Counter] = Workers_List[Counter+1];
        }
        NumberOfWorkers--;
        if (NumberOfWorkers<=0) {
            System.out.print("Error: No Workers left in firm!");
        }
    }

    boolean IsJobFree() {
        if (NumberOfWorkers<EmploymentTarget) {
            return true;
        } else {
            return false;
        }
    }

    void Plan_Current_Month(int Month_) {     //Plan action for Current Month

        if (Month_ > First_Month_Of_Planning) {
            // Change Wages
            boolean EmploymentTarget_Fullfilled_Last_Year = true;
            for (int Counter=1; Counter<=1; Counter++) {
                if (EmploymentTarget_Fullfilled[Month_-Counter]==false) { 
                    EmploymentTarget_Fullfilled_Last_Year = false;
                }
            }

            // Change the wage rate
            if (EmploymentTarget > NumberOfWorkers) {               // increase wage
                Wage = Wage * (1+Wage_Change_Speed*RandomGenerator.nextDouble());
                My_Agents.Firm_Reports_Used_Strategy(Month_, 0);
            } else if ( EmploymentTarget_Fullfilled_Last_Year ) {   // decrease wage
                Wage = Wage * (1-Wage_Change_Speed*RandomGenerator.nextDouble());
                My_Agents.Firm_Reports_Used_Strategy(Month_, 1);
            }

            // Remove one worker if:
            //    - Fire_Worker was triggered last month
            //    - There are more then one worker left
            //    - The NumberOfWorkers still larger than EmploymentTarget? This might be false if a worker has quit after the fireing decision being triggered.
            if ( (Fire_Worker == true) && (NumberOfWorkers>1) && (NumberOfWorkers>EmploymentTarget) ) {
                int HH_to_Fire = RandomGenerator.nextInt(NumberOfWorkers);
                Remove_Worker(HH_to_Fire);
                EmploymentTarget = NumberOfWorkers;
                Fire_Worker = false;
            }

            // Price and Hire/Fire decision
            if (Inventory < Min_Inventory_Fraction*Demand[Month_-1]) {                             // Inventory small
                Hire_Worker = true;
                Fire_Worker = false;
                My_Agents.Firm_Reports_Used_Strategy(Month_, 4);
                if (Price < Max_Profit * Wage/21/Technology_Parameter) {
                    if (RandomGenerator.nextDouble() < Price_Change_Probability) {
                        Price = Price * (1 + Price_Change_Speed*RandomGenerator.nextDouble());
                        My_Agents.Firm_Reports_Used_Strategy(Month_, 2);
                    }
                } 
            } else if (Inventory > Max_Inventory_Fraction*Demand[Month_-1]) {                      // Inventory large
                Hire_Worker = false;
                Fire_Worker = true;
                My_Agents.Firm_Reports_Used_Strategy(Month_, 5);
                if (Price > Min_Profit * Wage/21/Technology_Parameter) {
                    if (RandomGenerator.nextDouble() < Price_Change_Probability) {
                        Price = Price * (1 - Price_Change_Speed*RandomGenerator.nextDouble());
                        My_Agents.Firm_Reports_Used_Strategy(Month_, 3);
                    }
                }
            } else {
                // If firm is fine with the number of employees: make sure no open position is created and no one is fired
                EmploymentTarget = NumberOfWorkers;
                Hire_Worker = false;
                Fire_Worker = false;                
            }

            // If Hire_Worker has been triggered above, produce ONE open position. 
            if ( (Hire_Worker == true) && (EmploymentTarget <= NumberOfWorkers) ) {
                EmploymentTarget = NumberOfWorkers + 1;
                Hire_Worker = false;
            } else if (Fire_Worker == true) {
                EmploymentTarget = NumberOfWorkers - 1;
            } 

            /*if (Price < 1.01*Wage/Technology_Parameter/21) {    //Price Minimum
                Price = 1.01*Wage/Technology_Parameter/21;
                My_Agents.Firm_Reports_Used_Strategy(Month_, 2);
            }   */

        }

    }

    void Perform_Day(int Month_, int Day_) {
        Inventory_Daily[Day_] = Inventory;
        Production[Month_] = Production[Month_] + Technology_Parameter*NumberOfWorkers;
        Inventory = Inventory + Technology_Parameter*NumberOfWorkers;
    }

    void PayProfits(int Month_) {
        //Payout Profits
        if (Month_ > 5) {
            Profits = Math.max(0, Money - 1.1*Wage*NumberOfWorkers); // - 0.2*NumberOfWorkers*Wage;
            if (Profits < 0) {
                //Profits = Math.max(0, Money - 0.2*NumberOfWorkers*Wage);
                //System.out.println("--- negative Profits ---  " + MyFINumber + "   " + Profits);
            }

            double Aggr_HH_Money = 0;
            for (int Counter=0; Counter<My_Agents.Get_NumberOfHH(); Counter++) {
                Aggr_HH_Money = Aggr_HH_Money + My_Agents.Get_Household(Counter).Get_Money();
            }
            for (int Counter=0; Counter<My_Agents.Get_NumberOfHH(); Counter++) {
                My_Agents.Get_Household(Counter).Raise_Money( (1.0/1)*Profits * ((My_Agents.Get_Household(Counter).Get_Money())/Aggr_HH_Money)
                                                                +  (0.0/1)*Profits  *  1/My_Agents.Get_NumberOfHH()   );
            }
            Money = Money - Profits;
        }
    }
    
    void Perform_End_Of_Month(int Month_) {
        //Pay Wages
        if (Wage*NumberOfWorkers > Money) {
            double Rel_WageCut = ( Wage-(Money/NumberOfWorkers) ) / Wage;
            Wage = Money / NumberOfWorkers;
            My_Agents.Report_EndOfPeriodWageCut(Month_, MyFINumber, Rel_WageCut);
            //System.out.println("========= energecy wage cut ===========");
        }
        for (int Counter=0; Counter<NumberOfWorkers; Counter++) {
            My_Agents.Get_Household(Workers_List[Counter]).Firm_Payes_Wage(Wage);
            Money = Money - Wage;
        }
        
        if (EmploymentTarget <= NumberOfWorkers) {
            EmploymentTarget_Fullfilled[Month_] = true;
        }



    }


    void HH_Buyes_Goods(double Amount, int Month_) {
        Sales[Month_] = Sales[Month_] + Amount;

        Money = Money + Amount*Price;
        Inventory = Inventory - Amount;
    }


    void Shock(double value) {      //Perform some exogenous shock
        //Raise money amount
        Money = Money * value;
    }    
 
    void ResetRandomSeed (int RandomSeed_) {
        RandomGenerator = new Random(RandomSeed_);
    }
    
}
