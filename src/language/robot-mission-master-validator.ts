import type { ValidationAcceptor, ValidationChecks } from 'langium';
import { isInstance, Environment, Position, Mission, Expression, Size, Model, RobotMissionMasterAstType} from './generated/ast.js';
import type { RobotMissionMasterServices } from './robot-mission-master-module.js';

/**
 * Register custom validation checks.
 */
export function registerValidationChecks(services: RobotMissionMasterServices) {
    const registry = services.validation.ValidationRegistry;
    const validator = services.validation.RobotMissionMasterValidator;

    const checks: ValidationChecks<RobotMissionMasterAstType> = {
        Model: [
            validator.checkUniqueInstanceIDs,
        ],
        // Environment: validator.checkPositionsWithinEnvironment,
        // Mission: [
        //     validator.checkMissionStartPositionsWithinEnvironment,
        //     validator.checkTaskActionsWithinEnvironment
        // ],
        Size: validator.checkValidSize,
        Expression: validator.checkValidExpression,
    };
    registry.register(checks, validator);
}

/**
 * Implementation of custom validations.
 */
export class RobotMissionMasterValidator {
    
    checkUniqueInstanceIDs(model: Model, accept: ValidationAcceptor): void {
        const uniqueIDs = new Set<string>();

        model.instances.forEach(instance => {
            if (isInstance(instance) && 'id' in instance) {
                const id = instance.id;
                if (uniqueIDs.has(id)) {
                    accept('error', `Instance has non-unique ID '${id}'.`, { node: instance, property: 'id' });
                } else {
                    uniqueIDs.add(id);
                }
            }
        });
    }

    checkValidSize(size: Size, accept: ValidationAcceptor): void {  
        // const { length, width, height } = size;
        const length = evaluateExpression(size.length);
        const width = evaluateExpression(size.width);
        const height = evaluateExpression(size.height);
    
        if (height <= 0 || length <= 0 || width <= 0) {
            accept('error', `Size is invalid. All dimensions must be bigger than than 0`, { node: size });
        }
    } 

    checkValidExpression(expression: Expression, accept: ValidationAcceptor): void {
        try {
            evaluateExpression(expression);
        } catch (error) {
            if (error instanceof Error) {
                accept('error', error.message, { node: expression });
            } else {
                accept('error', 'An unknown error occurred during expression evaluation.', { node: expression });
            }
        }
    }

    // checkPositionsWithinEnvironment(environment: Environment, accept: ValidationAcceptor): void {
    //     const { length, width, height } = evaluateSize(environment.size);

    //     // Validate WorldObjects positions
    //     environment.objects.objects.forEach(object => {
    //         if (!isWithinBounds(object.position, length, width, height)) {
    //             accept('error', `WorldObject '${object.id}' is out of bounds in environment '${environment.id}'.`, { node: object, property: 'position' });
    //         }
    //     });

    //     // Validate Obstacles positions
    //     environment.obstacles.obstacles.forEach(obstacle => {
    //         if (!isWithinBounds(obstacle.position, length, width, height)) {
    //             accept('error', `Obstacle '${obstacle.id}' is out of bounds in environment '${environment.id}'.`, { node: obstacle, property: 'position' });
    //         }
    //     });
    // }

    // checkMissionStartPositionsWithinEnvironment(mission: Mission, accept: ValidationAcceptor): void {
    //     const environment = mission.environment.ref;
    //     if (environment) {
    //         const { length, width, height } = evaluateSize(environment.size);

    //         // Validate StartPositions
    //         mission.startPositions.startPositions.forEach(position => {
    //             if (!isWithinBounds(position, length, width, height)) {
    //                 accept('error', `StartPosition in mission '${mission.id}' is out of bounds in environment '${environment.id}'.`, { node: position });
    //             }
    //         });
    //     }
    // }

    // checkTaskActionsWithinEnvironment(mission: Mission, accept: ValidationAcceptor): void {
    //     const environment = mission.environment.ref;
    //     if (environment) {
    //         const { length, width, height } = evaluateSize(environment.size);

    //         mission.tasks?.tasks.forEach(task => {
    //             const action = task.action;
    //             if (isMoveTo(action) || isReturnToStart(action)) {
    //                 const position = action.position;
    //                 if (position && !isWithinBounds(position, length, width, height)) {
    //                     accept('error', `Action position in task of mission '${mission.id}' is out of bounds in environment '${environment.id}'.`, { node: action, property: 'position' });
    //                 }
    //             }
    //         });
    //     }
    // }

    //TODO: Check if WorldObjects or Obstacles
}


function evaluateExpression(expression: Expression): number {
    // Handle the case where expression is a simple literal
    if ('value' in expression && typeof expression.value === 'number') {
        return expression.value;
    }
    // Handle binary expressions
    else if ('operator' in expression && expression.operator && expression.left && expression.right) {
        const left = evaluateExpression(expression.left);
        const right = evaluateExpression(expression.right);
        switch (expression.operator) {
            case '+': return left + right;
            case '-': return left - right;
            case '*': return left * right;
            case '/': 
                if (right === 0) {
                    throw new Error("Division by zero");
                }
                return left / right;
            default: throw new Error(`Unsupported operation ${expression.operator}`);
        }
    }
    throw new Error("Unsupported expression type");
}

// function evaluateSize(size: Size): { length: number, width: number, height: number } {
//     return {
//         length: evaluateExpression(size.length),
//         width: evaluateExpression(size.width),
//         height: evaluateExpression(size.height)
//     };
// }

// function isWithinBounds(position: Position, length: number, width: number, height: number): boolean {
//     const { x, y, z } = evaluatePosition(position);
//     return x >= 0 && x <= length && y >= 0 && y <= width && z >= 0 && z <= height;
// }

// function evaluatePosition(position: Position): { x: number, y: number, z: number } {
//     return {
//         x: evaluateExpression(position.x),
//         y: evaluateExpression(position.y),
//         z: evaluateExpression(position.z)
//     };
// }