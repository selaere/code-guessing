fn main() {
    println!("{}", std::env::args().nth(1).expect("sorry").len());
}