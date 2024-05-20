grammar RobotMissionMaster


entry Model: 
    (definitions += Definition | environments+=Environment | missions+=Mission)*;    

// Environment 
Environment: 
    Size | 
    Objects |
    Obstacles;

Objects:
    objects += WorldObject;

WorldObject: 
    ID | 
    Position | 
    Size;

Obstacles:
    obstacles += Obstacle;

Obstacle: 
    Position | 
    ObstacleType | 
    Size;

terminal ObstacleType:
    ("Land" | "Water" | "Air" | "Weather");



// Robot
Robot: 
    PossibleActions | 
    RobotType | 
    Position | 
    StartPosition | 
    Battery;

PossibleActions:    
    actions+=Action*;
StartPosition:    
    startPosition=Position*;
Battery:    
    battery=Time;
terminal RobotType: 
    "Land" | "SurfaceWater" | "Underwater" | "Air";


Action: 
    ActionBlock | Move | Turn | MoveTo | Wait | Pickup | Drop | ReturnToStart | CustomAction;

ActionBlock:
    nname=ID '(' (action+=Action (',' action+=Action)*)? ')';  

Move: 
     (direction=Vector | length=Expression) ;
MoveTo: 
    position=Position;
Turn: 
    (angle=Expression | direction=Vector);
Wait: 
    time=Expression;
Pickup: 
    pickup=WorldObject;
Drop: 
    drop=WorldObject;
CustomAction: 
    description=STRING;
ReturnToStart:
    position=StartPosition;



Mission: 
    Environment | 
    Task | 
    Robot;


Tasks:
    tasks += Task;

Task: Robot | Action | Time;

Description: 
    description=STRING;
Actions: 
    actions+=Action*;
// MultipleRobotActions: 
//     multipleRobotActions+=Action*;
Time: 
    time=Expression*;





// Tuples with numerical info
Size: 
    "(" length=Expression "," width=Expression "," height=Expression ")";
Position: 
    "(" x=Expression "," y=Expression "," z=Expression ")";
Vector: 
    "(" x=Expression "," y=Expression "," z=Expression ")";


// Element syntax stuff
Parameter:
    name=ID ":" type=[Parameter];

Definition:
    DefinitionBlock | Mission | Environment | Robot | Tasks | WorldObject | Obstacle;

DefinitionBlock:    
    name=ID '{' 
        (parameters+=Parameter)* 
    '}';



// Number stuff
Expression: Addition;

Addition  infers Expression: 
    Multiplication     ({infer BinExpression.left=current} op=('+'|'-') right=Multiplication)*;

Multiplication infers Expression: 
    PrimaryExpression ({infer BinExpression.left=current} op=('*'|'/') right=PrimaryExpression)*;

PrimaryExpression: Literal | Reference | Group | NegativeExpression;

Literal:                
    value=NUMBER;
Reference:              
    value=[Parameter:ID];
Group:                  
    "(" group=Expression ")";
NegativeExpression:     
    "-" negativeExpression=Expression;


// Terminals
terminal ID returns string:         
    /[_a-zA-Z][\w_]*/;
// "text"
terminal STRING returns string: 
    /"[^"]*"/;
terminal NUMBER returns number:       
    /(?:(?:-?[0-9]+)?\.[0-9]+)|-?[0-9]+/;

// Ignore whitespaces
hidden terminal WS:                 
    /\s+/;
// // and /* */ comments
hidden terminal ML_COMMENT:         
    /\/\*[\s\S]*?\*\//;
hidden terminal SL_COMMENT:         
    /\/\/[^\n\r]*/;
