export class Close extends CustomEvent {
    constructor() {
        super(Close.type);
    }

    static get type() {
        return 'close';
    }
}
export class Submit extends CustomEvent {
    constructor() {
        super(Submit.type);
    }

    static get type() {
        return 'submit';
    }
}