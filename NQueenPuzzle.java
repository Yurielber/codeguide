public class NQueenPuzzle {
    static int total = 0;

    final static int N = 4;

    public static void prettyPrint(int[] queenPosition){
        for(int i = 1; i < queenPosition.length; i++){
            for(int column = 1; column <= N; column++){
                System.out.print(queenPosition[i] == column ? "Q ":"□ ");
            }
            System.out.println();
        }
        System.out.println();
    }

    public static void placeAQueen(int[] columnIndexQueen, int targetRow) {
        if (targetRow == N + 1) {
            total++;
            prettyPrint(columnIndexQueen);
        }
        else {
            for (int columnIndex = 1; columnIndex <= N; columnIndex++) {
                boolean isValid = true;
                for (int rowIndex = 1; rowIndex <= targetRow - 1; rowIndex++) {
                    if (columnIndexQueen[rowIndex] == columnIndex || Math.abs(targetRow - rowIndex) == Math.abs(columnIndex - columnIndexQueen[rowIndex])) {
                        isValid = false;
                        break;
                    }
                }
                if (isValid) {
                    columnIndexQueen[targetRow] = columnIndex;
                    placeAQueen(columnIndexQueen, targetRow + 1);
                }
            }
        }
    }

    public static void main(String[] args) {
        int[] queenPositions = new int[N + 1];
        placeAQueen(queenPositions, 1);
        System.out.println(total);
    }
}
