bring cloud;
bring http;
bring util;

let schedule = new cloud.Schedule(rate: 10h) as "sync-schedule";
let notificationSuccess = new cloud.Topic() as "sync successful";
let notificationFailure = new cloud.Topic() as "sync failure";
let syncQueue = new cloud.Queue({ retentionPeriod: duration.fromMinutes(20) }) as "sync queue";
let counter = new cloud.Counter({ initial: 0 }) as "counter";
let total = new cloud.Counter({ initial: 0 }) as "total";
let bucket = new cloud.Bucket({ public: false }) as "sync bucket";

pub struct Post {
    userId: num;
    id: num;
    title: str;
    body: str;
}

pub struct MessageEnvelope {
    batchId: str;
    batchSize: num;
    timestamp: num;
    post: Post;
}

syncQueue.setConsumer(inflight (msg: str) => {
    if (counter.peek() == total.peek()) {
        log("Duplicate message");
        return;
    }
    let json = Json.parse(msg);
    let envelope = MessageEnvelope.fromJson(json);
    let post = envelope.post;
    if (post.id >= 0) {
        bucket.putJson("{post.id}", json);
        counter.inc();
    }
    if (counter.peek() == envelope.batchSize) {
        notificationSuccess.publish("success processed {total.peek()} posts of {envelope.batchSize}");
        counter.set(0);
    } else {
        log("processed {counter.peek()} of {envelope.batchSize}");
    }
});

schedule.onTick(inflight () => {
    let res = http.get("https://jsonplaceholder.typicode.com/posts");
    if (!res.ok) {
        log({res});
        return;
    }

    let json = Json.parse(res.body);
    let posts = Json.entries(json);
    total.set(posts.length);

    let batchId = util.uuidv4();
    let timestamp = datetime.utcNow().timestamp;
    let batchSize = posts.length;

    for data in posts {
        log(Json.stringify(data));
        let post = Post.fromJson(data.value);
        let envelope : MessageEnvelope = {
            batchId,
            timestamp,
            batchSize,
            post
        };
        syncQueue.push(Json.stringify(envelope));
    }
});

notificationSuccess.onMessage(inflight (msg) => {
    log(msg);
});