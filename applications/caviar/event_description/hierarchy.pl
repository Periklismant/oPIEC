%------- Event Hierarchy -------%

% dependency(_ToBeComputedFirst, _Target).
dependency(person, fighting).
dependency(person, meeting).
dependency(person, moving).
dependency(person, leaving_object).
%dependency(distance, close).
dependency(close, fighting).
dependency(close, meeting).
dependency(close, moving).
dependency(close, leaving_object).

