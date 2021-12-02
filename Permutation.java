import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

public class Permutation {

    static List<List<Integer>> result = new LinkedList<>();

    public static List<List<Integer>> permute(int[] nums){
        List<Integer> track = new ArrayList<>();
        backtrack(track, nums);
        return result;
    }

    /**
     *
     * @param path
     * @param choices
     * end condition: choices 所有元素均出现在 path中
     */
    public static void backtrack(List<Integer> path, int[] choices){
        if (path.size() == choices.length){
            result.add(new LinkedList(path));
            return;
        }

        for (int i = 0; i < choices.length; i++){
            if (path.contains(choices[i])){
                continue;
            }
            // TODO: make choice
            path.add(choices[i]);

            backtrack(path, choices);

            // TODO: withdraw last action
            path.remove(path.size() - 1);
        }
    }

    public static void main(String[] args) {
        int[] nums = {1, 2, 3};
        List<List<Integer>> all = permute(nums);
        for (List<Integer> choice : all){
            System.out.println(Arrays.deepToString(choice.toArray()));
        }
    }
}
