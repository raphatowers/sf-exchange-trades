export class Close extends CustomEvent {
    constructor() {
        super(Close.type);
    }

    static get type() {
        return 'close';
    }
}