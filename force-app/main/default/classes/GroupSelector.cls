public class GroupSelector implements IGroupSelector {
    public interface IGroupSelector {
        List<GroupMember> selectMembersByGroupTypesAndNames(List<String> types, List<String> names);
    }

    private static IGroupSelector selectorInstance;
    public static IGroupSelector getInstance() {
        if (selectorInstance == null) {
            selectorInstance = new GroupSelector();
        }

        return selectorInstance;
    }

    public List<GroupMember> selectMembersByGroupTypesAndNames(List<String> types, List<String> names) {
        List<Group> groups = [SELECT Id FROM Group WHERE type = :types and Name = :names];
        return [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :groups];
    }
}