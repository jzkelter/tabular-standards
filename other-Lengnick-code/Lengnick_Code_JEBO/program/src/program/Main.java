package program;

public class Main {

    public static void main(String[] args) {
        //args 1: Silent, Seed, Folder, NumberOfMonth, ShockMonth, ParameterOfInterest

        boolean Silent_;
        if (args.length > 0) {
            if (args[0].compareTo("true") == 0) {
                Silent_ = true;
            } else {
                Silent_ = false;
            }
        } else {
            Silent_ = false;
        }

        int Seed_;
        if (args.length > 1) {
            Seed_ = Integer.parseInt(args[1]);
        } else {
            Seed_ = 50;
        }

        String Folder_;
        if (args.length > 2) {
            Folder_ = args[2];
        } else {
            Folder_ = "OutputFolder";
        }

        int NumberOfMonths_;
        if (args.length > 3) {
            NumberOfMonths_ = Integer.parseInt(args[3]);
        } else {
            NumberOfMonths_ = 2000;
        }

        int ShockMonth_;
        if (args.length > 4) {
            ShockMonth_ = Integer.parseInt(args[4]);
        } else {
            ShockMonth_ = -1;
        }

        double ParameterOfInterest_;    // This parameter can be a different one in each simulation (see Simulation.java) depending on the research question
        if (args.length > 5) {
            ParameterOfInterest_ = Double.parseDouble(args[5]);
        } else {
            ParameterOfInterest_ = -1;
        }



        Simulation My_Simulation = new Simulation();
        My_Simulation.setPriority(Thread.MIN_PRIORITY);
        My_Simulation.Start(Silent_, Seed_, Folder_, NumberOfMonths_, ShockMonth_, ParameterOfInterest_);

    }

}
