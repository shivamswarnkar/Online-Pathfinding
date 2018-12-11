# Online-Pathfinding

For a quick overview, look at our [presentation](https://github.com/shivamswarnkar/Online-Pathfinding/blob/master/Presentation.pdf).
For more details, read our [report](https://github.com/shivamswarnkar/Online-Pathfinding/blob/master/FinalProjectReport.pdf). 

Intro:

In this project we aim to find different methods to solve Online Pathfinding problem. In this  simulation, a disk robot is simulated in matlab to navigate an unknown environment while trying  to reach a goal. There are two methods used to implement the navigation. The first is Repetitive  Soft Subdivision Search (RSSS), where the robot runs a soft subdivision search algorithm on the  map it is building each time it scans. The second is Bounded Modified Subdivision Search  (BMSS), where the algorithm uses Subdivision Search approach with new classifier predicates.  BMSS is supposed to be a modified and efficient solution for Online Pathfinding, which  eliminates the repetitive computations done by RSSS.


Contributors

Names:	
Shivam Swarnkar		NYU ID:N18289822
Kamal S. Fuseini	NYU ID: 10420300
 
 -> Final Report.pdf 
 -> MainGUI.m   	{run this file to run the project}
 -> RSSS folder 	{contains files for RSSS algorithm}
 -> BMSS folder 	{contains files for BMSS algorithm}
 -> Common folder 	{contains common files used by RSSS & BMSS}


Info for use: 
 (See Final Report.pdf Apendix for more detailed informations)

Note : Explored map, time and box visited are updated after each iteration in algorithm. In some cases, if iteration involves a lot of computing, then you may see unchanged explored map, time and box visited values. In this condition, some buttons may not respond quick. If you face this condition then just wait for some time. 

User Guide : 
Run the MainGui.m file to run the project which will show the following GUI. There are mainly four panels : Input Map (to show input map), Explored Map (to show so far explored map), Map Control ( to show/hide subdiv, path and laser), System control (to set input file, scan range and algorithm to run) and Observation Panel (to ovbserve the time, box visited and to pause/stop the running algorithm). User can use toolbar tools to zoom in/out and move the Input and Explored maps.

Environmnet files: 
env0.txt env1.txt env2.txt env4.txt env5.txt env6.txt. {for more info, see Result section of Final Report.pdf}

ORIGINALITY STATEMENT: ”This writeup is my own work alone, referencing only the sources described in the SOURCE STATEMENT above. Electronically Signed:[Shivam Swarnkar] [Kamal S. Fuseini]”.
