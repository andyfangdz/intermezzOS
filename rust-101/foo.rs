use std::process;

fn main() {
    let mut a = 0;

    for _ in 0..10 {
        a = a + 1;
    }

    process::exit(a);
}
