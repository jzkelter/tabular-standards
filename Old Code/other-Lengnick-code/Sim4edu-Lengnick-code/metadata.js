var sim = sim || {};
sim.model = sim.model || {};
sim.scenario = sim.scenario || {};
sim.config = sim.config || {};

var oes = oes || {};
oes.ui = oes.ui || {};
oes.ui.explanation = {};

/*******************************************************
 Simulation Model
********************************************************/
sim.model.name = "LengnickBaselineEconomy-1";
sim.model.title = "Lengnick's Baseline Economy";
sim.model.systemNarrative =
    "<p>Lengnick's Baseline Economy (LBE) consists of two types of economic " +
    "actors only: <em>households</em> playing the roles of " +
    "workers/employees and consumers, and <em>firms</em> playing the roles " +
    "of employers and producers/suppliers. All firms produce and sell the " +
    "same abstract <em>consumption good</em> that is bought (and consumed) " +
    "by households.</p>" +
    "<p>LBE represents an economic system without growth. The numbers of " +
    "households and firms are fixed (there is neither population growth " +
    "nor shrinkage). Households do not <q>die</q> by starvation. When their " +
    "income shrinks, they adapt by cutting their consumption. Firms do not " +
    "get bankrupt. When their liquidity shrinks, they adapt by cutting " +
    "wages.</p>" +
    "<p>Consumption goods are produced and bought daily while labor is " +
    "bought monthly. Households buy consumption goods only from a limited " +
    "number of firms, their preferred suppliers, which they update " +
    "continuously. Consumption expenditure increases with personal wealth, " +
    "but at a decaying rate. Households are employed by at most one firm, " +
    "their employer. They continuously search for an employer that pays a " +
    "higher wage.</p>";
sim.model.shortDescription =
    "The LBE model is based on discrete time with days as time units. A " +
    "month consists of a <i>StartOfMonth</i> event followed by 21 " +
    "<i>EachDay</i> events representing the 21 consecutive working days of " +
    "a  month, which are followed by an <i>EndOfMonth</i> event. In addition " +
    "to these three event types, the model is composed of the two object " +
    "types <i>Household</i> and <i>Firm</i>. At the start of a month, firms " +
    "adjust their wage rate and consumption goods price as well as their " +
    "number of employees, while households search for cheaper vendors and " +
    "for a job (if unemployed) or a better paid job (if employed), as well " +
    "as decide on their monthly consumption budget. On each day, households " +
    "purchase consumption goods and firms produce new consumption goods " +
    "depending on their number of workers. At the end of a month, firms " +
    "distribute profits, pay wages, and decide about firing a worker. " +
    "Households receive their wage and may adjust their reservation wage.";
sim.model.source =
    "<a href='https://doi.org/10.1016/j.jebo.2012.12.021'>Agent-based " +
    "macroeconomics: A baseline model</a> by M. Lengnick, in " +
    "<em>Journal of Economic Behavior &amp; Organization</em>, " +
    "vol. 86, 2013.";
sim.model.license = "CC BY-NC";
sim.model.creator = "Luis Gustavo Nardin";
sim.model.contributors = "Gerd Wagner";
sim.model.created = "2018-02-16";
sim.model.modified = "2018-09-10";