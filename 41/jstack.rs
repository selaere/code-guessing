use std::io::{Write,stdin,stdout};
use wasmtime::{Engine, Module, Store, Caller, Func, Instance, Extern, Result};
use anyhow::anyhow;

fn i(mem: &[u8], i: i32) -> i32 { i32::from_le_bytes(mem[i as usize*4..(i as usize+1)*4].try_into().unwrap()) }

fn fmt(mem: &[u8],     mut x: i32) -> String { use String as S;
    x=i(mem, x);   let mut y = (x as u32 >> 2) as i32;
    match ((x&4)>>2,(x&2)>>1,(x&1)) {
        (0,0,0)=>{ let mut s = S::from('['); for j in 0..i(mem, y+1){ if j!=0{s.push(' ');}; s.push_str(&fmt(mem, y+2+j)); } s + "]" },
        (_,1,0)=>{ let mut s = S::new();     while y!=0             { s.insert(0,(96 + y%32) as u8 as char); y>>=5;        } s       },
        (1,0,0)=>  S::from((33+(x>>3)) as u8 as char),
        (_,_,1)=>  (x >> 1).to_string(),
        _ => unreachable!("how about you reach some bitches"),
    }
}

fn main() -> Result<()> {
    let engine = Engine::default();
    let module = Module::from_binary(&engine, include_bytes!("jstack.wasm"))?;
    let mut store = Store::new(&engine, ());
    
    let stk = Func::wrap(&mut store, |mut caller: Caller<'_,()>, _:i32| {
        let mem = caller.get_export("mem").and_then(|x| x.into_memory()).ok_or(anyhow!("no mem"))?.data(&caller);
        println!("{}:{}", fmt(mem, 1),fmt(mem, 2));
        Ok(())
    });
    let draw = Func::wrap(&mut store, |mut _caller: Caller<'_,()>, _: i32, _: i32| { println!("draw called"); });
    let instance = Instance::new(&mut store, &module, &[Extern::Func(stk), Extern::Func(draw)])?;
    let j = instance.get_typed_func::<i32, i32>(&mut store, "j")?;
    
    j.call(&mut store, 18)?;
    let mut jj = |c:&str|->Result<()> { for i in c.chars() { j.call(&mut store, i as i32)?; } Ok(()) };
    let mut input = String::new();
    jj(&std::fs::read_to_string("false.jstack")?)?;
    loop {
        print!(" "); stdout().flush()?;
        stdin().read_line(&mut input)?;
        if input.starts_with('\'') {
            jj("[")?; for c in input.trim().chars().skip(1) { jj(&(c as u32).to_string())?; jj(" ")?; } jj("]!\n")?;
        } else { jj(&input.trim())?; jj("!\n")?; }
        input.clear();
    }
}