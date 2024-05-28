import type { ValidationAcceptor, ValidationChecks } from 'langium';
import { isInstance, Expression, Size, Model, RobotMissionMasterAstType} from './generated/ast.js';
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
        Size: validator.checkValidSize
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