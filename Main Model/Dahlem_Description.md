# Dahlem Description

## 1. Overview 
### 1.1 Rationale
*What is the object under consideration? What is the intended usage of the model? Which issues can be investigated?*

The model is intended as an extensible general-purpose agent-based model (ABM) of an economy that introduces both Land and Organization to macroeconomic ABMs, two of the four factors of production emphasized by classical economics of a century ago. [^1] The other two factors, Labor and Capital, have already been included in many macroeconomic ABMs. The model can be used to investigate a number of issues:
- The influence of land availability and productivity on the economy and, conversely, the influence of economic activity on the productive capacity of land. 
- The influence of supply network structures on macroeconomic patterns
- The influence of indexed pricing methods (a method of Organization) on economic patterns and changes in ecological integrity


### 1.2 Agents
*What kind of agents are considered in the model? Is there a refined taxonomy of agents? Are there agent groupings which are considered relevant?*

The agents in the model are firms, land plots, and households. Their relationships are illustrated in Figure 1 below. 

**Firms** are of one of three generic types: 
1. *primary good firms* (pg-firms) require land to produce their output. In the current model they are conceptualized as agricultural firms.
2. *consumer good firms* (cg-firms) are any firms that sell directly to households. A consumer good firm can also be a primary good firm (e.g. a farmer who sells produce at a farmer's market directly to consumers)
3. *intermediate good firms* (ig-firms) are any firms that do not sell directly to consumers and do not require land to produce their output. In general, they are "intermediate" between primary good firms and consumer good firms. An example in the real world might be a firm that buys wheat from pg-firms, processes it into flour, and then sells it to bakeries.

In addition to these generic classifications, a firms are further defined by their input needs. A firm may require inputs from another type of firm to produce its outputs. So, two different types of firms might both be ig-firms, but different types because they require different inputs. 

**Land plots** are associated with pg-firms. The area and productive capacity per are of a firm's land plot constrains its output. The land use practices of a pg-firm can impact the productive capacity of the land they use. Land plots are considered "agents" and not "other entities" in the model (see next section) because they do run procedures in the model and change their internal state. They are also implemented as a type of agent in the actual code (written in NetLogo).

**Households** relate to firms in three ways:
1. *Employees*: households seek employment from firms and supply one unit of labor in exchange for a wage
2. *Consumers*: households buy goods from cg-firms
3. *Investors*: households can invest money to help a firm start up and then will subsequently receive dividends from the firm's profits. 


![](Econ Petri Dish Structure.png?raw=true)

**Figure 1: A)** A schematic of the relationships between land, firms, and household in the simple case in which a single type of firms produces primary goods and sells them directly to household. **B)** A schematic representation of an arbitrary firm network, in this case consisting of one type of primary good firm, two intermediate good firms, and one consumer good firm.

### 1.3 Other Entities
The network of firm-firm interactions and household-firm interactions are time evolving entities that do not represent decision-making entities, although these networks are implemented uses "link" agents in NetLogo. Links between firms represent trade agreements and links between households and firms represent either employment, customer, or investor relationships. 


### 1.4 Boundaries
*What are additional inputs to the model at runtime? Which outside influences on the model are hence represented?*

There are not model inputs at runtime. 

### 1.5 Relations
*What kind of relationships structure the agents’ interactions? To which extent do these represent institutions?*

As mentioned in section 1.3, agents' interactions are structured on a network. Each type of network represents a different institution:
- The supply-chain network between firms represents supply contracts which are negotiated in an open market. 
- The network of employment links between households and firms represents employment relations which are formed in an open labor market. 
- The network of consumer links between households and cg-firms represent a free consumer good market. 
- The network of investment links between households and firms represent ownership relations between households and firms which arise from an open investment market. 


### 1.6 Activities
*What kind of actions and interactions are the agents engaged into?*
- Firms 
	- Estimate demand and produce goods to try to fulfill demand
	- Sell goods to either households or other firms
	- Hire and lay off workers in the labor market to have enough workers to fulfill demand
	- Pay wages to workers
	- Pay dividends of profits to owners
- Households 
	- search for jobs on the labor market
	- earn money by working for firms and by receiving dividends from firms they have ownership in
	- buy consumer goods
- Land
	- Is improved or degraded over time based on the land use practices of pg-firms
	- Endogenously renews (improves) at a rate based on its current productive capacity. 


## 2. Design Concepts
### 2.1 Time, activity patterns and activation schemes
*What is the basic sequence of events in the model? Are activities by agents triggered by a central clock or by actions respectively messages sent by other agents? What is the interpretation of one time unit in the model?*

Time is modeled discretely and the activities of the agents are triggered by a central clock. One time unit can be interpreted as month. The general activity of agents is split into two parts: planning during the beginning of the month and producing/consuming during the month. At the beginning of the month, firms go out of business if they are out of money and replaced. Then firms forecast demand and plan production for the coming month. Household search for employment. Firms then pay workers and dividends from remaining profits. Households then plan consumption. During the month, firms buy input goods and produce output goods and households buy and consumer consumer goods. See section 3 for a more detailed sequence of events. 



### 2.2 Interaction protocols and information flows
*What are the general properties of the protocols governing the interaction between agents? How is determined which agents can interact with each other? What kind of information is available to each agent? If agents interact within institutional frameworks like firms or markets, what are the main properties of these institutions?*

Firm interactions can be divided into two categories: (1) establishing new links in the given interaction network and (2) interacting on the existing network. These two steps are described for each of the four interaction networks. 

**Supply Chain Network**
- At the beginning of each month, firms that require inputs search to establish new framework agreements with firms that produce the inputs they need. 
- During the month, firms buy inputs from one of the firms they already have a framework agreement with, starting with cheapest framework agreement. 

The only global information firms have about other firms is the average price of firms in their industry which they use to adjust price. All other information exchange is through framework agreements. 

**Employment Network**
- At the beginning of each month, firms layoff workers they project they won't need to meet upcoming demand. 
- At the beginning of each month, unemployed households search for employment and employed households, with some probability, search for higher paid better employment. 
- After the employment search is over, firms pay their employees for the upcoming month

**Consumer Good Market**
Each household keeps a certain number of consumer links with cg-firms.
- At the beginning of each month, households search a few firms to see if they can replace one of their current consumer links with a superior one (based on price or availability of goods)
- During the month, consumer buy goods from cg-firms they currently have links with (either in random order or sorted on price)

**Ownership network**
- Whenever a firm goes out of business, it is replaced. The new firm has to raise startup funds from households who then have equity links with this firm. 
- Firms pay dividends to the owners of the firm, represented by equity links. 


### 2.3 Forecasting
*Are agents in the model forward looking or purely backward looking? If agents are forward looking, what is the basic approach to modeling forecasting behavior?*

Firms forecast demand for the upcoming period. They do this based on an exponentially decaying weighted average of past sales. 

### 2.4 Behavioral Assumptions and Decision Making
*Based on which general concepts is decision making behavior of the different types of agents modeled? If the decision making of certain agents is influenced by their beliefs, how are these beliefs formed?*

Agents are boundedly rational and have only partial information. They base their decisions on heuristic rules. For example, if a firm expects increased demand and it can raise production to satisfy demand, it does so. If it can't, it raises prices. 

### 2.5 Learning
*Are decision rules of agents changed over time? If yes, which types of algorithms are used to do this?*

Decision rules are not changed over time. Firms do adjust their output decisions, price, and wage rate, but these just represent parameters within fixed decision rules. 

### 2.6 Population Demography
*Can agents drop out of the population and new agents enter the population during a simulation run? If yes, how are exit and entry triggered?*

The population of households and of land plots is constant. Firms that run out of money go bankrupt and replaced by a new firm. 

### 2.7 Levels of Randomness
*How do random events and random attributes affect the model?*

There are two main sources of randomness in the model:
- The order in which agents execute their behaviors
	- This can have large impacts on individual agents. For example, the last household to search for employment is likely to stay unemployed. 
- The various search/matching processes in each market/network


### 2.8 Miscellaneous
*Any important aspects of the used modeling approach that do not fit any of the items above should be explained here, for example, mathematical properties of the model.*

The model is designed to support arbitrary supply chain network complexity (although there can only be one type of cg-firm). This is implemented by having an input file that specifies the types of firms and which firms they take inputs from. Various supply chain networks can be tested without changing the model code. 

## 3. Functional Specification
### 3.1 Description of Agents and Other Entities
*What, in detail, are the Agents and Other Entities in the model?* 
*For each kind of Agents/Other Entities, what are the model state variables and parameters? List their type, that is, dimensions and admissible range, a short description of what they represent, units of measurement, how often they are updated (in models with different time scales) and how they are initialized.*

### 3.1.1 Firms
**State variables**:
- `inventory`: amount of goods stored and ready to be sold (>= 0)
- `month-production`: stores how much the firm produced this month
- `price`: a number which is the firm's desired selling price. For cg-firms this is their price. For other firms, this is the price they will set new framework agreements to be equal to
- `wage-rate`: a number representing the firm's wage. Can't go below `MIN-WAGE-RATE`
- `liquidity`: the amount of liquid cash the firm has on hand
- `months-without-vacancies`: the number of months since a firm has had a vacancy
- `desired-n-workers`: the number of workers the firm wants
- `previous-sales`: sales last period
- `demand`: demand experienced last month. If a firm sold out, demand might be higher than previous sales
- `firm-location`: for pg-firms, this stores the land they are associated with
- `competency`: for pg-firms this is a number representing how much the firm improves/degrades the land each period. If it is negative, the firm degrades the land. If it is positive, the firm improves the land. 
- `current-profits`: stores what the firm's profits were last period

**Parameters**:
- `firm-type`: a numerical label for the firm type. This is determined by the input structure JSON files referenced in `setup-structure`
- `input-data`: a table of the type of inputs the firm needs and what the productivity of each input is. Determined when the firm is created. 
- `tech-parameter`: determines how much each worker produces 

### 3.1.2 Households
**State variables**:
- `reservation-wage`: the minimum wage that this household is willing to accept
- `demanded-consumption`: the consumption that this household desires in the upcoming period
- `liquidity`: the amount of money the household has available
- `largest-firm-visited`: the largest cg-firm visited last tick. In some configurations this is used when deciding which firms to visit this period.

### 3.1.3 Land Plots
Land procedures have not been completed. Currently the patches have a fixed productive capacity. 
**State variables**:
- `productive-capacity`: determines how productive the land plot is currently


### 3.2 Sequence of events (general and then detailed)
*What Agent/Other Entity does what and in which order?*
*When are state variables updated? How are state variables updated (specify equations, diagrams, or pseudo code for algorithms related to rules-of-thumb, learning, adaptation, forecasting, interaction, etc)?*
*What information and with whom does each kind of agent exchange for decision-making? 


1. At the start of the period, firms without enough liquidity to pay a single worker go bankrupt and are replaced.
2. Firms, to plan the upcoming period:
	1. Estimate demand in the upcoming period
	2. Try to establish for framework agreements with firms they will buy inputs from
	3. Adjust wage rates based on success/failure in filling job positions
	4. Plan output based on previous sales (constrained by land) and adjust price
	5. Adjust desired labor (lays off workers or posts job openings)
3. Households:
	1. Update consumer links
	2. Adjust reservation wage
	3. Search for employment
4. Firms:
	1. Pay wages (happens at the beginning of the month to simplify firm planning and after households have searched for employment so new hires get paid)
	2. Distribute profits from prior period (this can only happen after paying wages)
5. Households set consumption for the month
6. Firms
	1. Buy input goods
	2. Produce output goods
7. Households buy and consume goods


Each of these events is described in more detail below. In most cases, when describing procedures that involve parameters, we use the parameter name from the model’s code directly instead of translating the parameter names from the code to mathematical symbols, which would then need to be translated back again by anyone who reads the code. Typical values for each parameter are included in parentheses when helpful. We do use mathematical notation in select cases when we think it facilitates communication.

#### 3.2.1 Bankruptcy and Firm Replacement (step 1)
At the beginning of each period, if a firm does not have enough liquidity to pay a single worker, it goes bankrupt. Any remaining liquidity it has is returned to shareholders. A new firm is then created which raises start-up capital from households equal to `STARTUP-LIQUIDITY`. The new firm asks households in a random order for funds. Households are willing to invest  up to `LIQUIDITY-WILLING-TO-INVEST` (typically 50%) of their current liquidity in the new firm, but their investment is only accepted if it represents at least `MIN-INVESTMENT-FRAC` (typically 10%) of the total value the firm is raising. In this way, there is an emergent class of capitalists based on wealth rather than a hard-coded class of capitalists as in Assenza et al. (2015)[^2]. Households own a fraction of the firm in proportion to what fraction of the startup funds they provided. The firm is initialized with `INITIAL-CONSUMER-LINKS` (typically 20) consumer-links , otherwise, it would usually fail to sell anything the first period and immediately go out of business. These initial consumer links can be thought of as being due to an initial advertising campaign. The new firm is also automatically given the plot of the land that the bankrupt firm vacated. 

#### 3.2.2 Firms Estimate Demand (step 2.1)
Firms estimate demand based on a rolling average of past sales, $S_{ave}(t)$ which is updated by the sales of the previous period by the following equation:
$$S_{ave}(t)=mS_{ave}(t-1)+(1-m)s(t)$$
Where:
- $s(t)$ is sales in the time period, $t$, that just past
- $m$  is a `FIRM-MEMORY-CONSTANT` between 0 and 1 that determines how much the firm remembers/weights previous average sales compared to the prior period’s sales.

#### 3.2.3 Try to establish for framework agreements with firms they will buy inputs from price (step 2.2)
There are two options in the model for establishing framework agreements. In the first option, firms keep a `N-FRAMEWORK-AGREEMENTS` at all times. If they have less than this (because one or more of their framework agreements expired), they establish new framework agreements with however firms they need to in order to have `N-FRAMEWORK-AGREEMENTS` number of framework agreements. 

In the second option, there is no limit on the number of framework agreements firms can have. Instead, firms search for new agreements each tick (whether for their inputs or to sell their outputs) and successfully establish some agreements based on the parameter `MEAN-NEW-AGREEMENTS-PER-MONTH`. 

Framework agreements are initialized with an index, an index-multiplier, and an expiration date `FRAMEWORK-DURATION` months after the current month. The index-multiplier is set such that the value of the index times the index-multiplier equals the price the selling firm wishes to sell at when the framework agreement is created. Later, if the index value changes, the price of the framework agreement will change as well. 

#### 3.2.4 Firms Adjust Wage Rates (step 2.3)
Firms adjust wages based on their success or failure in hiring. If a firm wanted to hire a worker last month and failed, it increases its wage to attract workers. On the other hand, if a firm has had no vacancies for the past `MONTHS-TO-LOWER-WAGE` (typically 12) months, the firm decreases wages. In either case, the increase/decrease is by a random fraction chosen uniformly between 0 and `MAX-WAGE-CHANGE` (typically 0.2). 


#### 3.2.5 Firms adjust planned output and price (step 2.4)
Ideally, firms want to fully satisfy their expected demand. Since demand may exceed expectations, firms try to keep a buffer stock of `DESIRED-BUFFER-FRAC` (typically 50%) of expected demand . So, after production and prior to sell-ing goods, firms aim to have 150% of expected demand in stock. Goods are non-perishable in the model. This means that if a firm has already built up its buffer, it rarely has to produce much more than expected demand. Firms may not be able to produce enough to have 150% of expected demand in stock before sales begin due to limited land, liquidity, or failure to hire adequate workers. As this is the planning stage, only the first two limitations come into play, and they determine how many workers the firm will aim to have this period. The number of workers a firm desires is equal to target production divided by the “tech-parameter” which determines labor productivity. This assumes that production is a linear function of labor (no changing returns to scale). The following pseudo-code describes the process of firms to plan output and their desired number of workers:

```
set target_production = 1.5 * expected_demand – current_inventory

if target_production > total productive capacity of land:
	set target_production = total productive capacity of land

set target_n_workers = target_production / tech_parameter

if liquidity < target_n_workers * wage-rate:
	reduce target_n_workers to maximum that can be afforded given liquidity
```

After planned output has been decided, the firm adjusts its price. Following Delli Gatti et al. (2011)[^3], a firm will not increase both output and price. A firm will raise prices only if all three of the following conditions are met:
1. Demand was higher than expected last period (which means expected demand this period is higher than last period)
2. The firm is unable to satisfy expected demand this period (either due to lack of liquidity to hire workers, or due to reaching the maximum productive capacity of the land).
3. The firm’s price is less than average price of other firms

The rationale for these conditions is that firms aim to increase market share before increasing unit profits. If condition 1 is met but not 2, this means the firm will try to meet the increased expected demand at the current price. If conditions 1 and 2 are both true but not 3, the firm will not risk losing market share by raising prices further above the average price of other firms.

A firm will decrease price if the following three conditions are met:
1. Demand was significantly less than expected last period, as measured by inventory being `BUFFER%-TO-LOWER-PRICE` (typically 120%) or more of the ideal buffer amount
2. The firm has enough liquidity to meet expected demand this period
3. The firm’s price is more than the average price of other firms

Condition 1 guarantees there is surplus. Condition 2 checks that the firm is able to fulfill expected demand, which suggests there will probably still be surplus. If this is true and the firm’s price is above the current average, the firm decreases price to try gain market share.



#### 3.2.6 Firms adjust labor (step 2.5)
If a firm has fewer workers than desired, it automatically has a job opening(s) available. It is then left to households searching for jobs to find these firms. If a firm has more workers than desired, it will attempt to lay off workers. Rather than keep track of labor contract lengths for each worker, we instead allow firms to lay off workers probabilistically. The firm attempts to lay off each work-er it doesn’t want and succeeds with probability equal to the parameter `LAYOFF-PROBABILITY`. A low layoff probability is equivalent to long labor contracts and a high layoff probability is equivalent to short labor contracts. 

In addition, a firm that cannot afford to pay its current number of workers lays off as many workers as needed so that it will be able to afford the wage bill.

#### 3.2.7 Households update consumer links (step 3.1)
Households have `N-TRADING-LINKS` (typically 7) consumer links . If they have fewer than this (due to a firm going out of busi-ness) they create new trading links. If a household has more than `N-TRADING-LINKS` consumer links, it randomly deletes them until the right number is reached. 

After guaranteeing they have enough consumer links, households probabilistically search for more desirable trading links. With probability equal to `PROB-REPLACE-FIRM-PRICE` (typically .25), the household will pick a random firm and, if its price is cheaper than the household’s most expensive current consumer link, will delete its most expensive consumer link and create one with the cheaper firm. Then, with probability  equal to `PROB-REPLACE-FIRM-QUANT` (typically 0.5), the household will pick one firm that failed to satisfy its demand last period (if one exists) and replace it with the randomly selected firm.

#### 3.2.8 Households adjust reservation wage (step 3.2)
If a household is unemployed, it decreases its current reservation wage to fraction of its current reservation wage determined by `RES-WAGE-CHANGE` (typically 90%). If the household is employed and its current wage is above its reservation wage, it increases its reservation wage to equal its current wage. 

#### 3.2.9 Households search for employment (step 3.3)
An unemployed household checks `SEARCH-N` (typically 5) randomly chosen firms for job openings and takes a job with the first one that offers a wage above the household’s reservation wage. An employed house-hold will check one random firm for a better paying job if its wage is below its reservation wage or with probability equal to 10% . If the randomly chosen firm has a job opening at a better wage, the household switches jobs. 

#### 3.2.10 Firms pay wages and distribute profits (step 4)
At this point, all employment is set for the month and firms pay their workers at their current wag-es. In case sales are lower than expected, firms keep some liquidity in reserve equal to `BUFFER-LABOR-FRACTION` (typically 30%) of current labor costs. Whatever liquidity remains is distributed to households with equity in the firm in proportion to their equity. 

#### 3.2.11 Households set consumption for the month (step 5)
Households, having been paid, set their consumption for the month based on the equation:
$$C=L^{\alpha}$$
Where:
- $C$ is planned consumption (`demanded-consumption` in the code)
- $L$ is the household's current liquidity 
- $\alpha$ is a parameter determining diminishing marginal utility in consumption (` DIMINISHING-UTILITY-CONSTANT` in the code)

Based on this equation, consumption always increases with increased liquidity, but unless $\alpha=1$, the increase is sub-linear. 

#### 3.2.12 Firms buy input goods (step 6.1)
Firms rank their framework agreements by their current prices and input order goods to try to make sure they have enough inputs to produce their expected demand. The firm stops buying if any of the following occur:
- they have fulfilled their demand
- they run out of money 
- they have visited all the firms they have framework agreements with 

#### 3.2.13 Firms produce output goods (step 6.2)
Firms produce output based on the number of workers they have, their stock of input goods, and in the case of pg-firms, land constraints. Output is linear with the number of workers (output = n-workers * tech-parameter).

For pg-firms though, there is an upper limit on production given by the total productive capacity of the land which equals land area times productive capacity per area. This is equivalent to an assumption that each worker can work a certain area of land and there is no benefit from additional labor applied to the land. 

#### 3.2.14 Households buy and consume goods 
Household visit the firms they have consumer links with one at a time, either in a random order or ranked by price (determined by `pick-cheapest-firm?`) and at-tempt to satisfy their demand by buying from that firm. If the firm runs out of inventory, the household visits the next consumer firm up until it either satisfies its demand or runs out of consumer links. 

### 3.3 Initialization
*How is the model initialized? Which kind of input is needed?*
*How is the initial state obtained from the input?*
*Are the initial values chosen arbitrarily or based on data? In the latter case, what kind of data is needed?*

The model is initialized with a JSON file loaded into the variable `setup-structure` and a number of parameters on the interface of the NetLogo model including:
- `n-households`: the number of households (this stays fixed)
- `n-firms`: the total number of firms. If there is more than one type defined in `setup-structure` their relative proportions have to be defined there as well. 
- `index-in-use`: the index to be used in framework agreements

A number of other parameters are initialized on the NetLogo model interface. Scrolling down on the interface shows all of these parameters. All initial values are currently chosen arbitrarily. 

Agent initializations described in the following sections. 

#### 3.3.1 Households
Households are initialized with:
- One employment link with a random firm. 
- `N-TRADING-LINKS` consumer links with random cg-firms
- `STARTUP-LIQUIDITY` amount of money

#### 3.3.2 Firms
Firms are initialized with at least one employee. They then raise funds from households equal to `STARTUP-LIQUIDITY`. They are also initialized with framework agreements. PG-firms are also initialized associated with a land plot. 

#### 3.3.3 Land Plots
Land plots are initialized with a productive capacity. 


### 3.4 Run-time input
*Does the model use input from external sources that drive the model? Are there data files or other models that represent these external processes? If so, what kind of data is required to feed the model at runtime? Include, if possible, references to relevant literature, or a description of the external models. If a model does not use external data, please state this here.*

The model does not use any runtime input. 


## References

[^1]: Marshall, A. 1920 [1979]. Principles of Economics, Eighth Edition. London: Macmillan.
[^2]: Assenza, T., Delli Gatti, D., & Grazzini, J. (2015). Emergent dynamics of a macroeconomic agent based model with capital and credit. _Journal of Economic Dynamics and Control_, _50_, 5–28. [https://doi.org/10.1016/j.jedc.2014.07.001](https://doi.org/10.1016/j.jedc.2014.07.001)
[^3]: Delli Gatti, D., Desiderio, S., Gaffeo, E., Cirillo, P., & Gallegati, M. (2011). _Macroeconomics from the Bottom-up_. Springer Science & Business Media.
