import pytest
from check_commit_msg import check


@pytest.mark.parametrize(
    "message",
    [
        "feat(sim): add market prices (S9.T01)",
        "fix(core): clamp rng seed (S1.T06)",
        "ci: add workflows (S0.T04)",
        "docs: update roadmap",
        "chore(repo): tidy ignore rules",
        "Merge branch 'main'",
    ],
)
def test_valid_messages(message):
    assert check(message) is None


@pytest.mark.parametrize(
    "message",
    [
        "abc",
        "feat: missing task id",
        "feature(sim): wrong type (S1.T01)",
        "feat(sim): bad task id (S1.T1)",
    ],
)
def test_S0_T03_TC2_invalid_messages_are_rejected(message):
    assert check(message) is not None
