grammar RobotMissionMaster


entry Model: 
    (definitions += Definition)*;    


// Element syntax stuff
Definition:
    DefinitionBlock | 
    Mission | 
    Environment | 
    Robot | 
    Tasks | 
    Objects |
    WorldObject | 
    Obstacles |
    Obstacle;

DefinitionBlock:    
    name=ID '{' 
        (properties+=Property)* 
    '}';

Property:
    PropertyBlock | 
    NameID |
    Weight |
    Position |
    Vector |
    Size |
    ObstacleType |
    RobotType |
    Battery |
    PossibleActions |
    Description |
    PickedEnvironment |
    PickedRobots |
    RobotStartPositions;

PropertyBlock:
    name=ID ":" value=Property;





// Environment 
Environment: 
    NameID &
    Size &
    Objects &
    Obstacles;


WorldObject: 
    NameID &
    Position &  
    Size &
    Weight;

Obstacle:
    NameID &
    Position &
    ObstacleType &
    Size;

Objects:
    objects+=WorldObject*;

Obstacles:
    obstacles+=Obstacle*;

ObstacleType:
    obstacleType=("Land" | "Water" | "Air" | "Weather");





// Robot

Robot: 
    NameID &
    RobotType &
    Battery &
    PossibleActions; 
    

Battery:
    battery=Expression;

PossibleActions:    
    actions+=Action*;

RobotType: 
    robotType=("Land" | "SurfaceWater" | "Underwater" | "Air");



Action: 
    ActionBlock | Move | Turn | MoveTo | Wait | Pickup | Drop | ReturnToStart | CustomAction;

ActionBlock:
    robot=[Robot:ID] name=[Action:ID] '('  ')';  


Move: 
     direction=Vector length=Expression;
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
    position=[Mission:RobotStartPositions];






// Mission

Mission:
    NameID &
    Description &
    PickedEnvironment &
    PickedRobots &
    RobotStartPositions &
    Tasks;


PickedEnvironment:
    environment=[Environment:ID];
    
PickedRobots:
    robots+=[Robot:ID] (',' robots+=[Robot:ID])*;

RobotStartPositions:
    robot=[Robot:ID] startPositions+=Position ("," robot=[Robot:ID] startPositions+=Position)*;

Description: 
    description=STRING?;
Tasks:
    tasks += Task*;

Task: 
    robot=[Robot:ID] action=Action;


// MultipleRobotActions: 
//     multipleRobotActions+=Action*;
// Time: 
//     time=Expression*;



// General

NameID:
    name=ID;

Weight:
    weight=Expression;

// Tuples with numerical info
Size: 
    size = "(" length=Expression "," width=Expression "," height=Expression ")";
Position: 
    position = "(" x=Expression "," y=Expression "," z=Expression ")";
Vector: 
    vector = "(" x=Expression "," y=Expression "," z=Expression ")";






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
    value=[Property:ID];
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
