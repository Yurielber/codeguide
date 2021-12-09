import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Solution {
    /**]
     * N = triangle.size()
     * 0 =< i < N-1
     *           | f[i-1][0] + Value[i][0]                     j = 0
     * f[i][j] = | Min{ f[i-1][j-1], f[i-1][j]} + Value[i][j]  0 < j < i
     *           | f[i-1][i-1] + Value[i][i]                   j = i
     */
    public static int minimumTotal(List<List<Integer>> triangle){
        int N = triangle.size();
        int[][] f = new int[N][N];

        // base case
        f[0][0] = triangle.get(0).get(0);

        // i range [1, N-1]
        for(int i = 1; i<N; i++){
            f[i][0] = f[i-1][0] + triangle.get(i).get(0);
            for(int j = 1; j < i; j++){
                f[i][j] = Math.min(f[i-1][j-1], f[i-1][j]) + triangle.get(i).get(j);
            }
            f[i][i] = f[i-1][i-1] + triangle.get(i).get(i);
        }

        int minTotal = f[N-1][0];
        for (int i = 1; i < N; i++){
            minTotal = Math.min(minTotal, f[N-1][i]);
        }
        return minTotal;
    }

    public static void main(String[] args) {
//        [[2],[3,4],[6,5,7],[4,1,8,3]]
        List<List<Integer>> triangle = new ArrayList<>();

        triangle.add(Arrays.asList(2));
        triangle.add(Arrays.asList(3, 4));
        triangle.add(Arrays.asList(6, 5, 7));
        triangle.add(Arrays.asList(4, 1, 8, 3));

        System.out.print(minimumTotal(triangle));
    }
}
