create table themes(
    name varchar
);

create table questions(
    text varchar,
    theme_id int references themes(rowid)
);

insert into themes(name) values
                             ('Essential Ruby Interview Questions');

insert into questions(text, theme_id) values
                                          ('What is Ruby, and why is it popular among developers?', 1),
                                          ('How do you create a class in Ruby', 1),
                                          ('What is an instance variable', 1),
                                          ('What are blocks and how are they used in Ruby', 1),
                                          ('What is the yield keyword used for in Ruby', 1),
                                          ('How do you create a class in Ruby', 1),
                                          ('Explain the difference between a local variable and a global variable', 1),
                                          ('How do you concatenate strings in Ruby?', 1),
                                          ('What does the ''nil'' value represent in Ruby', 1),
                                          ('How can you convert a string to an integer', 1),
                                          ('Describe how to use array methods such as ''map'' and ''select', 1),
                                          ('Explain the ''=='' and ''==='' operator', 1),
                                          ('What is a Range, and how do you create one', 1);