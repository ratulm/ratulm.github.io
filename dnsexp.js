///<reference path="..\..\..\..\Shared\Src\Content\Script\Declarations\Shared.d.ts" />
(function () {
    var localHost = window.location.hostname;
    var localProtocol = window.location.protocol + "//";

    if (localProtocol === "https://") {
        return;
    }

    // URLs to test
    var test1 = localProtocol + _G.IG + ".clo.footprintdns.com/apc/";
    var test2 = localProtocol + _G.IG + ".test1.nrb.footprintdns.com/apc/";
    var test3 = localProtocol + _G.IG + ".test2.nrb.footprintdns.com/apc/";

    // Use absolute hostname for resource so we can find W3C resource by name
    var localUrl = localProtocol + localHost + "/apc/";

    var warmupImg = "trans.gif";
    var testImg = "17k.gif";

    var requestTimeout = 2000;
    var requestDelay = 2000;

    var reportHostMsr = "fplog.cloudapp.net";
    var reportParams = "&Type=Event.ApEdge_A&prot=" + window.location.protocol + "&DATA=";

    var reportUrls = [
        localProtocol + reportHostMsr + _G.lsUrl + reportParams,
        localProtocol + localHost + _G.lsUrl + reportParams
    ];

    var warmupUrls = [
        test1 + warmupImg,
        test2 + warmupImg,
        test3 + warmupImg
    ];

    var testUrls = [
        test1 + testImg,
        test2 + testImg,
        test3 + testImg,
        localUrl + testImg + "?" + _G.IG
    ];

    // Maps a URL in testUrls to a measurement ID by index
    var urlIds = ["CLO", "NRB1", "NRB2", "ANY"];

    var runTest = function () {
        // Don't delay executing this. Don't need to pass in onComplete function.
        flight(testUrls, requestTimeout, 0, reportUrls, urlIds, null);
    };

    // Run the DNS warmup URLs and then run test URLs.
    // This is just to warm up DNS so no need for a reportUrl or url2id function
    flight(warmupUrls, requestTimeout, requestDelay, null, null, runTest);

    /**
    * Creates a JSON measurement report.
    */
    function createReport(loadTimes, urlIds) {
        var results = {};

        for (var i = 0; i < urlIds.length; i++) {
            var urlId = urlIds[i];
            results[urlId] = loadTimes[i];
        }

        return JSON.stringify(results);
    }

    /**
    * Runs a measurement test for a user provided list of URLs and sends a JSON report
    * back to a report server.
    */
    function flight(urlsToTest, reqTimeout, reqDelay, reportUrls, urlIds, onComplete) {
        var startTime;
        var timeoutId;
        var loadTime = [];
        var indexOfFirstProbe = Math.floor(Math.random() * urlsToTest.length);
        var nextIndex = 0;
        var numberProbesSent = 0;
        var target;

        function doProbe(nextIndex) {
            if (timeoutId != null) {
                sb_ct(timeoutId);
            }

            if (startTime != null) {
                loadTime[nextIndex] = new Date().getTime() - startTime;
            } else {
                // Mark as timeout. If this is bootstrap call then this gets overwritten.
                loadTime[nextIndex] = -1;
            }

            nextIndex = (numberProbesSent + indexOfFirstProbe) % urlsToTest.length;
            target = new Image;
            if (numberProbesSent++ < urlsToTest.length) {
                // Start the next measurement probe
                startTime = new Date().getTime();
                target.onload = function () {
                    doProbe(nextIndex);
                };

                /*
                On error and on timeout:
                1. Set target.onload to null to avoid processing image if it loads
                while processing timeout callback.
                2. Set target.src to empty so that the browser stops the request.
                3. Set startTime to null so that loadTime entry isn't populated.
                */
                var errorHandler = function () {
                    target.onload = null;
                    target.onerror = null;
                    target.src = "";
                    startTime = null;
                    doProbe(nextIndex);
                };

                //Config to give up on the load after reqTimeout ms.
                timeoutId = sb_st(function () {
                    errorHandler();
                }, reqTimeout);

                target.onerror = function () {
                    //clear timeout callback
                    if (timeoutId != null) {
                        sb_ct(timeoutId);
                    }
                    timeoutId = null;
                    errorHandler();
                };

                target.src = urlsToTest[nextIndex];
            } else {
                if (reportUrls != null && reportUrls.length !== 0) {
                    /*
                    Generate a report.
                    First look for W3C resource timings and then fall back to less
                    accurate timing if W3C is not supported in this browser.
                    Second check because Firefox doesn't support resource timing yet.
                    */
                    if (window.performance && window.performance.getEntriesByName) {
                        for (var i = 0; i < urlsToTest.length; i++) {
                            var testUrl = urlsToTest[i];
                            var perfEntryArray = window.performance.getEntriesByName(testUrl);
                            if (perfEntryArray && perfEntryArray[0]) {
                                loadTime[i] = perfEntryArray[0].duration;
                            }
                        }
                    }

                    // Create JSON data report
                    var reportStr = createReport(loadTime, urlIds);

                    for (var i = 0; i < reportUrls.length; i++) {
                        var reportUrl = reportUrls[i];
                        var reportImg = new Image;
                        reportImg.src = reportUrl + reportStr;
                    }
                }

                // Execute onComplete function now that probes are finished
                if (onComplete != null) {
                    onComplete();
                }
            }
        }

        // wait for reqDelay(ms) to prevent confusing page load events of the parent page
        // or delaying things the page itself wants to do when it finishes loading
        sb_st(function () {
            doProbe(0);
        }, reqDelay);
    }
    ;
})();
