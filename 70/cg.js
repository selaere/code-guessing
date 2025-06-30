R={s:-1}
async function move(dir) {
    let r = await (await fetch("/extra/game70",{
        method: dir?"POST":"GET",
        body: dir && JSON.stringify({dir}),
        headers: {"Content-Type": "application/json"}
    })).json()
    renderGame(r)
    if (R.s<r.s) R=r
    return r;
}
async function step() {
    for (dir of create_path(R.grid))
        await Promise.all(dir.map(move));
}

function create_path(grid) {
    let at=grid.indexOf("@")
    let pl=grid.indexOf("+")
    let bo=grid.indexOf("*")

    let dy=(pl>>4)-(at>>4)
    let dx=pl%16-at%16
    let x = Array(dx>0?dx:-dx).fill(dx>0?"right":"left")
    let y = Array(dy>0?dy:-dy).fill(dy>0?"down":"up")
    return bo==-1 ? [x.concat(y)] :
        dx==0 && at%16==bo%16 ? [[pl%16?"left":"right"],y,[pl%16?"right":"left"]] :
        dy==0 && (at>>4)==(bo>>4) ? [[pl>>4?"up":"down"],x,[pl>>4?"down":"up"]] :
        (bo>>4)==(at>>4) || bo%16==pl%16 ? [y,x] : [x,y]
}

await move()
while (R.score<2025) await step()