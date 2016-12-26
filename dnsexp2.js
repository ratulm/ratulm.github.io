///<reference path="..\..\..\..\Shared\Src\Content\Script\Declarations\Shared.d.ts" />
(function () {

    var localHost = "204.79.197.200"; //FIX ME! window.location.hostname;
    var localProtocol = window.location.protocol + "//";

    var monitorID = "AZR"

    var sharedIG = guid(); //this guid is shared across CLO, NRB, and ANY monitorIDs
    var IGs = [sharedIG, sharedIG, guid(), guid(), sharedIG];

    // URLs to test
    var test1 = localProtocol + IGs[0] + ".clo.footprintdns.com/apc/";
    var test2 = localProtocol + IGs[1] + ".nrb.footprintdns.com/apc/";
    var test3 = localProtocol + IGs[2] + "." + monitorID + ".msnetworkanalytics.testanalytics.net/ap/";
    var test4 = localProtocol + IGs[3] + "." + monitorID + ".msnetworkanalytics.testanalytics.net/ap/";
    var test5 = localProtocol + IGs[4] + ".any.footprintdns.com/apc/";

    var warmupImg = "trans.gif";
    var testImg = "17k.gif";

    var requestTimeout = 2000;
    var requestDelay = 2000;

    var reportHostMsr = "report.footprintdns.com/trans.gif?"
    var reportParams = "&prot=" + window.location.protocol + "&MonitorID=" + monitorID + "&DATA=";

    var reportUrls = [
        localProtocol + reportHostMsr + reportParams,
    ];

    var warmupUrls = [
        test1 + warmupImg,
        test2 + warmupImg,
        test3 + warmupImg,
        test4 + warmupImg
    ];

    var testUrls = [
        test1 + testImg,
        test2 + testImg,
        test3 + warmupImg + "?" + IGs[2], //use warmup image for Azure
        test4 + warmupImg + "?" + IGs[3], //and here
        test5 + testImg + "?" + IGs[4] //disable any caching
    ];

    // Maps a URL in testUrls to a measurement ID by index
    var urlIds = [{"name":"CLO", "guid": IGs[0]}, 
                  {"name":"NRB", "guid": IGs[1]}, 
                  {"name": monitorID, "guid": IGs[2]},
                  {"name": monitorID, "guid": IGs[3]}, 
                  {"name": "ANY", "guid": IGs[4]}];

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
        var results = [];

        for (var i = 0; i < urlIds.length; i++) {
            var urlId = urlIds[i];
            results.push({'MonitorID': urlIds[i].name, 'RequestID':urlIds[i].guid, 'Result':Math.round(loadTimes[i])});
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
                                //console.log(testUrl);
                                //console.log(perfEntryArray);
                            }
                        }
                    }
    
                    //var pe = window.performance.getEntriesByType("resource");
                    //for (var i = 0; i < pe.length; i++){
                    //    console.log("Name:" + pe[i].name + " Duration:" + pe[i].duration);
                    //}
    
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
    };

    function guid() {
        //RFC4122 version 4 IDs
        function s4() {
            return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
        }
        return s4() + s4() + s4() + s4() + s4() + s4() + s4() + s4();
    }

})();
