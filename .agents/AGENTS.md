<RULE[user_global]>
When proposing or implementing advanced Swift concurrency primitives (such as `CheckedContinuation`, `AsyncStream`, or manual `Task` suspension), ALWAYS provide a brief, explicit explanation of the mechanical control flow. Specifically, clarify exactly where the task suspends and precisely which line of code "unlocks" or resumes it to return control to the caller. Do not treat concurrency flow as a black box.
</RULE[user_global]>

<RULE[user_global]>
If a prompt ends with a question without a clearly worded instruction to DO or IMPLEMENT, do NOT change or write any code. Just answer the question.
</RULE[user_global]>
