import { AstNode, LangiumDocument, LangiumCoreServices } from 'langium';
import { Model, Robot, Environment, Mission, Task, Action, WorldObject, Obstacle } from '../language/generated/ast.js';
import { isMove, isMoveTo, isPickup, isDrop, isReturnToStart, isWait, isTurn } from '../language/generated/ast.js';
import { URI } from 'vscode-uri';
import fs from 'fs';
import path from 'path';

export async function generateJsonFiles(services: LangiumCoreServices, document: LangiumDocument<AstNode>): Promise<void> {
    const model = document.parseResult.value as Model;
    const outputDir = path.join(path.dirname(URI.parse(document.uri).fsPath), 'missions');

    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir);<
    }

    model.instances.forEach(instance => {
        if (instance.mission) {
            const mission = instance.mission;
            const missionData = {
                description: mission.description?.description,
                environment: mission.environmentProperty?.environment?.ref ? getEnvironmentData(mission.environmentProperty.environment.ref) : null,
                robots: getRobotsData(mission.robotsProperty.robots.map(robot => robot.ref)),
                tasks: getTasksData(mission.tasks?.tasks || [])
            };
            const filePath = path.join(outputDir, `${mission.id.id}.json`);
            fs.writeFileSync(filePath, JSON.stringify(missionData, null, 2));
        }
    });
}

function getEnvironmentData(environment: Environment): any {
    return {
        id: environment.id,
        size: {
            length: environment.sizeProperty.size.length,
            width: environment.sizeProperty.size.width,
            height: environment.sizeProperty.size.height
        },
        objects: environment.objects.objects.map(obj => getObjectData(obj)),
        obstacles: environment.obstacles.obstacles.map(obstacle => getObstacleData(obstacle))
    };
}

function getObjectData(obj: WorldObject): any {
    return {
        id: obj.id.id,
        position: {
            x: obj.positionProperty.position.x,
            y: obj.positionProperty.position.y,
            z: obj.positionProperty.position.z
        },
        size: {
            length: obj.sizeProperty.size.length,
            width: obj.sizeProperty.size.width,
            height: obj.sizeProperty.size.height
        },
        weight: obj.weight.weight
    };
}

function getObstacleData(obstacle: Obstacle): any {
    return {
        id: obstacle.id.id,
        position: {
            x: obstacle.positionProperty.position.x,
            y: obstacle.positionProperty.position.y,
            z: obstacle.positionProperty.position.z
        },
        size: {
            length: obstacle.sizeProperty.size.length,
            width: obstacle.sizeProperty.size.width,
            height: obstacle.sizeProperty.size.height
        },
        obstacleType: obstacle.obstacleType.obstacleType
    };
}

function getRobotsData(robots: Robot[]): any {
    return robots.map(robot => ({
        id: robot.id.id,
        robotType: robot.robotType.robotType,
        battery: robot.battery.battery,
        capacity: robot.capacity.capacity
    }));
}

function getTasksData(tasks: Task[]): any {
    return tasks.map(task => ({
        robot: task.robot.ref,
        action: getActionData(task.action)
    }));
}

function getActionData(action: Action): any {
    if (isMove(action)) {
        return {
            type: 'Move',
            direction: {
                x: action.direction.vector.x,
                y: action.direction.vector.y,
                z: action.direction.vector.z
            },
            length: action.length.length
        };
    } else if (isMoveTo(action)) {
        return {
            type: 'MoveTo',
            position: {
                x: action.position.x,
                y: action.position.y,
                z: action.position.z
            }
        };
    } else if (isPickup(action)) {
        return {
            type: 'Pickup',
            object: action.pickupObject.ref
        };
    } else if (isDrop(action)) {
        return {
            type: 'Drop',
            object: action.dropObject.ref
        };
    } else if (isReturnToStart(action)) {
        return {
            type: 'ReturnToStart'
        };
    } else if (isTurn(action)) {
        if (action.angle) {
            return {
                type: 'Turn',
                angle: action.angle
            };
        } else if (action.direction) {
            return {
                type: 'Turn',
                direction: {
                    x: action.direction.x,
                    y: action.direction.y,
                    z: action.direction.z
                }
            };
        }
    } else if (isWait(action)) {
        return {
            type: 'Wait',
            time: action.time
        };
    }
    return {};
}
