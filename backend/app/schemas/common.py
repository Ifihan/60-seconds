from typing import Annotated

from pydantic import StringConstraints

AreaId = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        pattern=r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
    ),
]
AreaName = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=100)]
TopicName = Annotated[str, StringConstraints(strip_whitespace=True, min_length=1, max_length=200)]
Password = Annotated[str, StringConstraints(min_length=8, max_length=128)]
