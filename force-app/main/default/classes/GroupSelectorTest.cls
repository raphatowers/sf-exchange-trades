@IsTest(seeAllData=false)
private class GroupSelectorTest {
    @IsTest
    static void selectMembersByGroupTypesAndNames_typesDoNotMatch_emptyList() {
        // Given
        createQueue();

        // When
        List<GroupMember> actualMembers = GroupSelector.getInstance().selectMembersByGroupTypesAndNames(new List<String>{ 'NotQueue' }, new List<String>{ 'Trade reviewers' });

        // Then
        System.assertEquals(true, actualMembers.isEmpty());
    }

    @IsTest
    static void selectMembersByGroupTypesAndNames_namesDoNotMatch_emptyList() {
        // Given
        createQueue();

        // When
        List<GroupMember> actualMembers = GroupSelector.getInstance().selectMembersByGroupTypesAndNames(new List<String>{ 'Queue' }, new List<String>{ 'Trade followers' });

        // Then
        System.assertEquals(true, actualMembers.isEmpty());
    }

    @IsTest
    static void selectMembersByGroupTypesAndNames_typesAndNamesMatch_groupMembersReturned() {
        // Given
        User tradeUser = createQueue();

        // When
        List<GroupMember> actualMembers = GroupSelector.getInstance().selectMembersByGroupTypesAndNames(new List<String>{ 'Queue' }, new List<String>{ 'Trade reviewers' });

        // Then
        Set<Id> memberIds = new Set<Id>();
        for (GroupMember member : actualMembers) {
            memberIds.add(member.UserOrGroupId);
        }
        System.assertEquals(true, memberIds.contains(tradeUser.Id));
    }

    private static User createQueue() {
        Profile standardProfile = [SELECT Id FROM profile WHERE name = 'Standard User'];
		User tradeUser = new User(
			alias = 'test',
			email = 'testuser@testorg.com',
			emailencodingkey = 'UTF-8',
			lastname = 'Testing',
			languagelocalekey = 'en_US',
			localesidkey = 'en_GB',
			profileid = standardProfile.Id,
			timezonesidkey = 'Europe/London',
			username = 'commonselectortestuser@testorg.com'
		);
        insert tradeUser;

        Group queue = new Group(
            Type = 'Queue',
            Name = 'Trade reviewers'
        );
        insert queue;

        GroupMember tradeMember = new GroupMember(
            UserOrGroupId = tradeUser.Id,
            GroupId = queue.Id
        );
        insert tradeMember;

        return tradeUser;
    }
}